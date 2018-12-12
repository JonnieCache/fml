import React from 'react'
import {store} from 'store'
import distanceInWordsToNow from 'date-fns/distance_in_words_to_now'
import classnames from 'classnames'
import { CSSTransitionGroup } from 'react-transition-group'
import {sfxManager} from 'sfx_manager'
import Tag from 'components/tag'

export default class TaskRow extends React.Component {

  constructor(props) {
    super(props);
    
    this.complete = this.complete.bind(this);
    this.edit = this.edit.bind(this);
    this.ghostVanish = this.ghostVanish.bind(this);
    
    this.state = {
      ghosts: [],
      edited: false
    }
    
  }

  complete() {
    this.setState((newState)=>{
      newState.ghosts.push(this.props.task.value * this.props.combo);
      return newState;
    });
    sfxManager.beep();
    store.completeTask(this.props.task);
  }

  edit() {
    store.fire('TASK_EDIT_START', this.props.task);
  }

  tag() {
    return this.props.tags[this.props.task.tag_id];
  }
  
  ghostVanish(e) {
    e.currentTarget.remove();
  }
  
  render() {
    const buttons = [];
    if(this.props.task.state == 'incomplete'){
      buttons.push(
        <button key="complete" className="btn btn-sm btn-primary" onClick={this.complete}>Complete!</button>
      );
    }
    buttons.unshift(
      <button key="edit" className="btn btn-sm" onClick={this.edit}>Edit</button>
    )
    
    const tagElement = this.tag() && (
      <Tag {...this.props} tag={this.tag()} />
    );
    
    const recurringClass = classnames({
      'fa': true,
      'fa-lg': true,
      'fa-refresh': true,
      'active': this.props.task.recurring
    })
    
    const dailyClass = classnames({
      'fa': true,
      'fa-lg': true,
      'fa-calendar-o': true,
      'active': this.props.task.daily
    })
    
    const ghosts = this.state.ghosts.map((ghost)=> (<span key={ghost} onAnimationEnd={this.ghostVanish} className="value-ghost ghost-enter-active">{ghost}</span>));
    
    return (
      <div className="task-row" data-id={this.props.task.id}>
        <h4 className="">{this.props.task.name}</h4>
        <div className="task-row-data">
          <div className="tag-wrapper">{tagElement}</div>
          <i className={recurringClass}/>
          <div className="value">
            {ghosts}
            <span className="value-real">{this.props.task.value}</span>
          </div>
          <div className="btn-group" role="group">
            {buttons}
          </div>
        </div>
      </div>
    )
  }
}
