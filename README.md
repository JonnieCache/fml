![FML logo](/static/images/fml_logo.jpg)

## Fix My Life

FML is an app in which you give yourself tasks to do, and assign various point values to them. You log the completions of the tasks, and clock up a running total of points. In other words, it's a standard task tracking app with elements of gamification. It also has an ugly purple color scheme. [You can sign up and use it here.](http://fml.cleverna.me)

## Getting Started

FML is provided with a set of docker containers, see the [Deployment](#label-Deployment) section for details.

1. Clone the repo

    ```
    $ git clone https://github.com/JonnieCache/fml
    $ cd fml
    ```
    
2. Build the docker containers

    ```
    $ docker/build_docker.sh
    ```
    
3. Build the app

    ```
    $ docker-compose --project-name=fml -f docker/docker-compose.yml run build
    ```
    
4. Create and set up the database  
    FML requires a postgres database. You may need to alter the DB config environment variables passed to the container via modifications to `docker/docker-compose.yml`, or via arguments to the `docker-compose` executable, so that the container can see the postgres instance.
    
    *Don't use weak password-based authentication like this in production!*  

    ```
    $ echo "CREATE ROLE fml WITH PASSWORD 'fml' LOGIN; CREATE DATABASE fml_development WITH OWNER fml; " | psql postgres
    $ echo "CREATE EXTENSION citext" | psql fml_development
    $ docker-compose --project-name=fml -f docker/docker-compose.yml run app bundle exec rake db:migrate
    ```
    
5. Start the application server

    ```
    docker-compose --project-name=fml -f docker/docker-compose.yml up app
    ```

## Design

### Backend

FML is built in ruby and react. The backend is a fairly straightforward affair: DB access and data modelling is built on the superb [Sequel](https://github.com/jeremyevans/sequel) ORM by [Jeremy Evans](https://github.com/jeremyevans), and requests are served by the [Roda](https://github.com/jeremyevans/roda) framework, also from Evans. This is a new take on the sinatra model, and while it's somewhat unproven, my experiences with Sequel have been so good that I felt confident giving it a try.

The app depends on a postgresql database.

Most of the work is done in Plain Old Ruby Objects, put into arbitrary categories like 'Interactors' and 'Calculators'. Small models and thin controllers are the order of the day.

### State

State is pushed to the client through {StatePresenter} objects. This class accepts a {User} object and some selection of other domain objects and renders out a large JSON tree representing the state of the user's data. When the app is first loaded, it is supplied with the user object alone, and defaults to collecting all the relevant data to run the app into one object.
When update requests are made, the relevant model objects are supplied to the presenter and an identically structured JSON object is returned with the subset of data affected by the update.

Some deliberation happened as to whether to return one large unified state object, or to have multiple types of state updates and return the appropriate one when needed. In the end, as this is a simple app, I decided to take a hybrid approach: one exactly type of state object can be returned, but this may or may not describe the complete set of domain objects owned by the user. This works along with with the strategy used to store state in the frontend, described later in this readme.

### Frontend

With regard to the react frontend, the app is just complicated enough that the use of something like Redux would probably be justified. However I wanted to implement a similar structure from scratch, for educational/fun purposes.

The top level component is named `Router`. Continuing the NIH theme, React Router was eschewed in favor of a few lines of code to glue together the `route-recognizer` library with another for history management.

Once login is handled, the main app is rendered by the `Controller` component. 

As well as rendering the `App` component which actually starts drawing the UI, and providing some utility functions, `Controller` is the first place we start seeing references to the `store` singleton object. This is a plain old js object, and it acts as both an event bus as well as handling all requests to the server, and includes various utility functions related to these tasks.

Let's look at the flow of control when a user completes a task:

![Task completion sequence diagram](/static/images/fml_sequence_diagram_opt.svg)

We start at the aforementioned `Controller` component on the left. This renders our `TaskCard`, passing in the application state via props. The user clicks on the "complete" button, invoking the `complete()` method on the `TaskCard` component. This then calls the `completeTask()` method on the `store` object, passing in the task object. This function makes a http request to the server, ending up in `TasksController` on the server. Here we initialize a `TaskCompletionInteractor` object which does all the necessary interactions with the DB, and then a `StatePresenter` which renders the updated application state as a json object.

Next, control returns to the callback of our http request in the `store` object. This fires the `TASK_COMPLETED` event on the `store` object's event bus. This is handled in the `Controller` component. Here, the json representing the updated state from the server is merged into the state of the component, and then the interface is re-rendered in the usual way.

### A word on the `store` object and react state

The `store` object, as previously mentioned, is a singleton that handles communication with the 
server as well as acting as an event bus. I chose this design in order to avoid having to pass a reference all the way down through the component hierarchy, instead every component just imports the `store.js` file which exports an instance of the `Store` class. 

In fml, all state is stored in the top level `Controller` component. The entire state object is passed wholesale into the props of the `App` component using the spread attributes syntax. This pattern is repeated throughout the component hierarchy, such that every component has access to the entire application state. Of course, this access is read-only. With very few exceptions, no component stores any state of its own.

Intuitively, this feels excessive. We've thrown information hiding completely out of the window, probably along with a whole load of other rules. On the other hand, we don't have to keep track of anything whatsoever. There is one source of truth for the whole application, and as it can only be written to from one place, it's harder to shoot ourselves in the foot.

The idea was to have everything to do with the application's data be global, so it can be read from anywhere via props, and written to from everywhere, via the `store` object, while still keeping control over requests and data mangling all in one place. Long method chains as well as "relay-race" situations with the manual passing of objects down through deep component hierarchies were to be avoided.

I'm pretty happy with the way it's turned out. This seems like a decent solution for a smallish, single-developer application. I'm sure after several years of exposure to the real world, there will be a different story to tell.

## Testing/Deployment

### Testing

FML has a suite of rspec tests. Testing of the frontend is carried out via capybara integration tests in rubyland. There is unfortunately no jsland unit testing of the react components as yet.

### Deployment

#### Containers

FML comes with docker containers for builds and deployment. They are all built on alpine linux, and are as follows:

* `docker/ruby/Dockerfile`  
  Derived from the official alpine image, with the ruby interpreter and some associated libraries installed via apk. Bundler is then installed from rubygems. This custom container was used instead of the official ruby container in the interests of simplicity, and greater control over the environment.
  
  
* `docker/build/Dockerfile`  
  Derived from the above `fml-ruby` container. This container is intended for building FML, ie. installing the required ruby gems and npm packages, as well as running the webpack build process. The `CMD` value is set to `./build.sh`
  
  
* `docker/test/Dockerfile`  
  Derived from the `fml-ruby` container. This is for running the rspec suite, including headless integration tests. The Dockerfile adds `chromium` and `chromedriver` from apk to facilitate that. `CMD` is set to `./ci-rspec.sh`.
  
  
* `docker/app/Dockerfile`  
  Again, derived from `fml-ruby`. This container runs a single instance of the backend applicaion server, served by puma.
  
  
* `docker/web/Dockerfile`  
  This time derived from `nginx:alpine` Set up as a reverse proxy to the puma server and to serve the app's static files. Configuration is defined under `docker/web/nginx`, which the Dockerfile copies to `/etc/nginx`, replacing whatever configuration the parent container provides. The configuration is a pretty straightforward one, with the usual caching and gzip options.
  
#### Volumes and paths

All the above containers are intended to operate in the context of a full copy of the code tree, mounted into the containers at `/fml`. Starting from a fresh clone of the repository, running the `build` container will install the gems and build the javascript into that same directory. Similarly, the `app` container expects to find the built source tree mounted at `/fml`, and the `web` container expects the same, in order to serve the static files.

This design was chosen, instead of the perhaps more usual docker workflow where the build system produces a freestanding container as the primary artifact, because it is more flexible, and it better facilitates deployment as a set of different containers.

If the built source were compiled into a container, that container would have to include both nginx and puma, and some system to manage both processes. Alternatively, separate containers for puma and nginx could be used, with the app code compiled into both of them. This would then require them to be updated indepdendently, whereas this way they can both be run against the same tree. The application code changes regularly, whereas the container context changes rarely. With my design, an update copy of the application code can be cloned, built, and the same containers can be restarted, repointed to the updated code.

## Contributing

Make an issue, send a pull request, you know the drill.

FML has a suite of RSpec tests, please use them.

## Copyright

Copyright (c) 2018 Jonathan Davies. See [LICENSE](LICENSE) for details.
