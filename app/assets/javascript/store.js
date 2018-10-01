import 'whatwg-fetch';

class Store {
  constructor() {
    this.emptyTask = {
      name: '',
      description: '',
      value: 1,
      recurring: true,
      tag_id: null
    };
    this._callbacks = {};
  }
  
  on(event, callback){
    this._callbacks[event] = callback;
  }
  
  fire(event, payload){
    this._callbacks[event](payload);
  }
  
  
  updateNewTask(update) {
    Object.assign(this.newTask, update);
    this.fire('UPDATE', {newTask: this.newTask});
  }
  
  editTag(tag) {
    this._editTagCallback(tag)
  }

  request(uri, callback, options = {}) {

    options.headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/json'
    };
    
    if(window.localStorage.getItem('token') !== null) {
      options.headers['Authorization'] = window.localStorage.getItem('token');
    }
      
    fetch(uri, options).then(response => {
      if(response.status === 200) {
        response.json().then(callback);
      } else if(response.status == 401) {
        this.fire('LOGIN_REQUIRED');
      }
    });

  }
  
  getState() {
    return this.request('/state',
      (updatedState)=> this.fire('STATE_UPDATED', updatedState));
  }
  
  createTask(task) {
    return this.request('/tasks', (update)=> this.fire('TASK_CREATED', update), {
      method: 'POST',
      body: JSON.stringify(task)
    });
  }
  
  updateTask(task) {
    return this.request('/tasks', (update)=> this.fire('TASK_UPDATED', update), {
      method: 'PUT',
      body: JSON.stringify(task)
    });
  }
  
  updateTag(tag) {
    return this.request('/tags', (update)=> this.fire('TAG_UPDATED', update), {
      method: 'PUT',
      body: JSON.stringify(tag)
    });
  }
  
  completeTask(task) {
    return this.request(`/tasks/${task.id}/completions`, (update)=> this.fire('TASK_COMPLETED', update), {
      method: 'POST'
    });
  }
  
  login(creds) {
    return fetch('/login', {
      headers: {'Accept': 'application/json', 'Content-Type': 'application/json'},
      method: 'POST',
      body: JSON.stringify(creds)
    }).then((resp)=> {
      if(resp.status == 200) {
        window.localStorage.setItem('token', resp.headers.get('Authorization'));
        
        resp.json().then((json)=> {
          this.fire('LOGIN_SUCCESS', json);
        });
      } else if(resp.status == 401) {
        resp.json().then((json)=> {
          this.fire('LOGIN_FAILED', json);
        });
      }
    });
  }
  
  signup(creds) { 
    return fetch('/signup', {
      headers: {'Accept': 'application/json', 'Content-Type': 'application/json'},
      method: 'POST',
      body: JSON.stringify(creds)
    }).then((resp)=> {
      if(resp.status == 200) {
        window.localStorage.setItem('token', resp.headers.get('Authorization'));
        
        resp.json().then((json)=> {
          this.fire('SIGNUP_SUCCESS', json);
        });
      } else if(resp.status == 422) {
        resp.json().then((json)=> {
          this.fire('SIGNUP_FAILED', json);
        });
      }
    });
  }
  
  logout() {
    window.localStorage.removeItem('token');
    
    this.fire('LOGOUT_SUCCESS');
  }
  
}

export let store = new Store()
