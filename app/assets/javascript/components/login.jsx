import React from 'react'
import {store} from 'store'
import { CSSTransitionGroup } from 'react-transition-group'
import classnames from 'classnames'

export default class Login extends React.Component {
  constructor(props) {
    super(props);
    
    this.state = {
      login: "",
      password: "",
      error: undefined,
      ghosts: []
    }
    
    this.update = this.update.bind(this);
    this.login = this.login.bind(this);
    this.signup = this.signup.bind(this);
  }
  
  componentDidMount() {
    store.on('LOGIN_FAILED', (err)=> {
      this.setState((newState)=>{
        err.t = Date.now();
        newState.ghosts.push(err);
        newState.error = err;
        
        return newState;
      });
    });
  }
  
  update(e){
    let value;
    
    if(e.target.type == 'checkbox') {
      value = e.target.checked;
    } else {
      value = e.target.value
    }
    
    this.setState({[e.target.name]: value, error: undefined});
  }
  
  
  login(e) {
    e.preventDefault();
    
    store.login({login: this.state.login, password: this.state.password});
    
    return false;
  }
  
  signup(e) {
    e.preventDefault();
    
    store.fire("SIGNUP_START")
    
    return false; 
  }
  
   render() {
    const errorClass = classnames({
      'error-real': true,
      'd-none': this.state.error === undefined
    })
    
    const ghosts = this.state.ghosts.map((error)=> (<span key={error.t} className="error-ghost">Incorrect email/password</span>));
    
    return (
      <div className="d-flex flex-column">
        <img id="logo" src="/assets/img/fml_logo2.svg" alt="FML" className="d-block align-self-center login"/>
        <div className="modal-dialog login-card">
          <div className="modal-content">
            <div className="modal-header">
              <h1 className="login-header">Login to FML</h1>
            </div>
            <div className="modal-body">
              <div className="error">
                {ghosts}
                <div className={errorClass}>Incorrect email/password</div>
              </div>
              <form className="" onSubmit={this.login}>
                <div className="form-group">
                  <input className="form-control" type="email" value={this.state.login} onChange={this.update} name="login" placeholder="Email" autoFocus="true" />
                </div>
                <div className="form-group">
                  <input className="form-control" type="password" value={this.state.password} onChange={this.update} name="password" placeholder="Password" />
                </div>
                <div className="d-flex flex-row justify-content-between">
                  <div style={{padding: '0.375rem 0.75rem', lineHeight: 2}}>Don't have an account? <a onClick={this.signup} href="#/signup">Sign up now!</a></div>
                  <button type="submit" className="btn btn-primary">Login</button>
                </div>
              </form>
            </div>
          </div>
          
        </div>
      </div>
    )
   } 
}
