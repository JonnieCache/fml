import React from 'react'
import {store} from 'store'

export default class TaskCards extends React.Component {
  newTask() {
    store.fire('NEW_TASK_START');
  }
  
  render() {
    if(this.props.tasks.length > 0) {
      return null;
    }
    
    return (
      <div className="d-flex flex-column">
        <div className="modal-dialog login-card">
          <div className="modal-content">
            <div className="modal-header">
              <h1 className="login-header">No Tasks Yet!</h1>
            </div>
            <div className="modal-body text-center" onClick={this.newTask}>
              <h4 className="pointer">Click here or on the <button className="btn btn-sm add-task" title="Add new task"><i className="fa fa-plus"></i></button> in the top right to get started</h4>
            </div>
          </div>
          
        </div>
      </div>
    )
  }
}
