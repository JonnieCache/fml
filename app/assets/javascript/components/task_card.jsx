import React from 'react'
import {store} from 'store'
import distanceInWordsToNow from 'date-fns/distance_in_words_to_now'
import classnames from 'classnames'
import { CSSTransitionGroup } from 'react-transition-group'
import {sfxManager} from 'sfx_manager'
import Tag from 'components/tag'

export default class TaskCard extends React.Component {

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

  // editTag() {
  //   store.fire('TAG_EDIT_START', this.tag());
  // }
  
  tag() {
    return this.props.tags[this.props.task.tag_id];
  }

  
  // }
  // }
  // reorder(taskIds, sortable, event) {
  ghostVanish(e) {
  //   store.reorderTasks(taskIds);
  // }
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
      // <span key={this.tag().id} onClick={this.editTag} className="tag align-self-start" style={{backgroundColor: "#"+this.tag().color}}>{this.tag().name}</span>
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
      <div data-id={this.props.task.id} className="card">
        <div style={{display: 'flex'}} className="card-header">
          <h4 className="card-title align-self-center" style={{flex: 1}}>{this.props.task.name}</h4>
        </div>
        <div className="task-card card-block">
          <div className="card-text card-icons">
            <div className="d-flex justify-content-around">
              <div className="w-100 text-center">{tagElement}</div>
              <div className="w-100 text-center"><i className={recurringClass}/></div>
              <div className="w-100 text-center value">
                {ghosts}
                <span className="value-real">{this.props.task.value}</span>
              </div>
            </div>
          </div>
          {/*<div className="card-text"><small className="text-muted">Last completed {distanceInWordsToNow(task.last_completed_at)} ago</small></div>*/}
        </div>
        <div className="card-footer">
          <div className="btn-group" role="group">
            {buttons}
          </div>
        </div>
      </div>
    )
  }
}
