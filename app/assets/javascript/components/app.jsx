import React from 'react'
import NewTaskForm from 'components/new_task_form'
import EditTaskForm from 'components/edit_task_form'
import EditTagForm from 'components/edit_tag_form'
import TaskCards from 'components/task_cards'
import NoTasksPanel from 'components/no_tasks_panel'
import Login from 'components/login'
import NeedsMeters from 'components/needs_meters'
import SearchBox from 'components/search_box'
import { CSSTransitionGroup } from 'react-transition-group'
import mapValues from 'lodash.mapvalues'
import {store} from 'store'
import Shake from 'shake.js'

export default class App extends React.Component {
  constructor(props) {
    super(props);
    
    this.state = {
      overlayGhosts: []
    }
    
    this.shake = new Shake({
        threshold: 15,
        timeout: 1000
    });
    this.shake.start();
    
    this.spacebar = this.spacebar.bind(this);
    this.shakeEvent = this.shakeEvent.bind(this);
  }
  
  spacebar(e) {
    if(e.key == ' ' && !(e.target.tagName == 'INPUT')){
      e.preventDefault();
      store.fire('SEARCH_START');
      return false;
    }
  }
  
  shakeEvent(e) {
    store.fire('SEARCH_START');
  }
  
  componentDidMount() {
    window.document.addEventListener('keydown', this.spacebar);
    window.addEventListener('shake', this.shakeEvent, false);
    
    store.on('TASK_COMPLETED_FROM_SEARCH', (task) =>{
      this.setState((newState)=>{
        newState.overlayGhosts.push(task.value * this.props.combo);
        return newState;
      });
    });
  }
  
  componentWillUnmount() {
    window.document.removeEventListener('keydown', this.spacebar);
    window.removeEventListener('shake', this.shakeEvent);
    this.shake.stop();
  }
  
  newTask() {
    store.fire('NEW_TASK_START');
  }
  
  logout() {
    store.logout();
  }
  
  render(){
    if(!this.props.tasks){
      return (
        <p>Loading...</p>
      )
    } else {
      const ghosts = this.state.overlayGhosts.map((ghost)=> (<span key={ghost} className="value-ghost overlay-ghost">{ghost}</span>));
      return (
        <div>
          <header className="media justify-content-between">
            <div className="d-flex logo-holder">
              <img id="logo" src="/assets/img/fml_logo2.svg" alt="FML" />
              <NeedsMeters
                {...this.props}
              />
            </div>
            <div className="scores text-right">
              <p>Score: <span id="score">{this.props.score}</span></p>
              <p>Combo: {this.props.combo}x</p>
              <button className="btn btn-sm add-task" onClick={this.newTask} title="Add new task"><i className="fa fa-plus"></i></button>
              <button className="btn btn-sm logout" onClick={this.logout} title="Logout"><i className="fa fa-sign-out"></i></button>
            </div>
          </header>
          <TaskCards    {...this.props} />
          <NoTasksPanel {...this.props} /> 
          <NewTaskForm  {...this.props} />
          <EditTaskForm {...this.props} />
          <EditTagForm  {...this.props} />
          <SearchBox    {...this.props} />
          <div className="value">
            <CSSTransitionGroup
              transitionName="ghost"
              transitionEnterTimeout={1000}
              transitionLeaveTimeout={1000}
            >
              {ghosts}
            </CSSTransitionGroup>
          </div>
        </div>
      )
    }
  }
}
