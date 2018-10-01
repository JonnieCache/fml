import React from 'react'
import Controller from 'components/controller'
import Login from 'components/login'
import Signup from 'components/signup'
import RouteRecognizer from 'route-recognizer'
import createHistory from 'history/createHashHistory'
import {store} from 'store'

export default class Router extends React.Component {
  constructor(props) {
    super(props);
    
    this.router = new RouteRecognizer();
    this.history = createHistory();
    this.router.add([
      { path: '/tasks', handler: Controller }
    ]);
    this.router.add([
      { path: '/login', handler: Login }
    ]);
    this.router.add([
      { path: '/signup', handler: Signup }
    ]);
    
    this.state = {
      currentView: this.getCurrentView(),
      login: null
    }
  }
  
  navigate() {
    const newView = this.getCurrentView();
    
    if(newView == undefined){
      this.history.replace('/tasks');
    } else {
      this.setState({currentView: newView});
    }
  }
  
  getCurrentView() {
    const route = this.router.recognize(this.history.location.pathname);
    
    if(route == undefined){
      return undefined;
    } else { 
      return route[0].handler; 
    }
  }
  
  componentDidMount() {
    this.history.listen((location, action)=> this.navigate());
    this.navigate();
    
    store.on('LOGIN_REQUIRED', ()=> {
      this.history.replace('/login');
    });
    
    store.on('LOGIN_SUCCESS', (auth)=> {
      this.history.replace('/tasks');
    });
    
    store.on('LOGOUT_SUCCESS', ()=> {
      this.history.replace('/login');
    });
    
    store.on('SIGNUP_START', ()=> {
      this.history.replace('/signup');
    });
    
    store.on('SIGNUP_SUCCESS', (auth)=> {
      this.history.replace('/tasks');
    });
  }
  
  render() {
    let CurrentView = this.state.currentView;
    
    if(!CurrentView){
      return (<p>Loading...</p>)
    } else {
      return (<CurrentView {...this.state} />)
    }
    
  }
}
