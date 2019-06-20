import React from 'react'
import {store} from 'store'
import { CSSTransitionGroup } from 'react-transition-group'
import classnames from 'classnames'

export default class Signup extends React.Component {
  constructor(props) {
    super(props);
    
    this.emptyError = {err: ""};
    
    this.state = {
      login: "",
      password: "",
      'password-confirm': "",
      error: this.emptyError,
      ghosts: []
    }
    
    this.update = this.update.bind(this);
    this.signup = this.signup.bind(this);
    this.login = this.login.bind(this);
  }
  
  componentDidMount() {
    store.on('SIGNUP_FAILED', (err)=> {
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
    
    this.setState({[e.target.name]: value, error: this.emptyError});
  }
  
  
  signup(e) {
    e.preventDefault();
    
    store.signup({login: this.state.login, password: this.state.password, 'password-confirm': this.state['password-confirm']});
    
    return false;
  }
  
  login(e) {
    e.preventDefault();
    
    store.fire("LOGIN_REQUIRED");
    
    return false; 
  }
  
   render() {
    const errorClass = classnames({
      'error-real': true,
      'd-none': this.state.error == this.emptyError
    })
    
    
    var errMsg = '';
    if(this.state.error["field-error"] !== undefined) {
      errMsg = this.state.error["field-error"][1];
      errMsg = errMsg.charAt(0).toUpperCase() + errMsg.substr(1)+'.';
    }
    
    const ghosts = this.state.ghosts.map((error)=> {
      return (
        <span key={error.t} className="error-ghost">{error.error}:<br />{errMsg}</span>
      );
    });
    
    return (
      <div className="d-flex flex-column">
        <img id="logo" src="/assets/img/fml_logo2.svg" alt="FML" className="d-block align-self-center" style={{width: '50vw', marginTop: '15vh', marginBottom: '5vh'}}/>
        <div className="modal-dialog login-card" style={{width: '50vw'}}>
          <div className="modal-content">
            <div className="modal-header">
              <h1 className="login-header">Signup for FML</h1>
            </div>
            <div className="modal-body">
              <div className="error">
                {ghosts}
                <div className={errorClass}>{this.state.error.error}:<br />{errMsg}</div>
              </div>
              <form className="d-flex flex-column" onSubmit={this.signup}>
                <div className="form-group">
                  <input className="form-control" type="email" value={this.state.login} onChange={this.update} name="login" placeholder="Email" autoFocus />
                </div>
                <div className="form-group">
                  <input className="form-control" type="password" value={this.state.password} onChange={this.update} name="password" placeholder="Password" />
                </div>
                <div className="form-group">
                  <input className="form-control" type="password" value={this.state['password-confirm']} onChange={this.update} name="password-confirm" placeholder="Confirm Password" />
                </div>
                
                <div className="d-flex flex-row justify-content-between">
                  <div style={{padding: '0.375rem 0.75rem', lineHeight: 2}}>Already have an account? <a onClick={this.login} href="#/login">Log in here</a></div>
                  <button type="submit" className="btn btn-primary">Signup</button>
                </div>
              </form>
            </div>
          </div>
        </div>
      </div>
    )
   } 
}
