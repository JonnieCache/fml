import React from 'react'
import {store} from 'store'
import TaskForm from 'components/task_form'

export default class NewTaskForm extends TaskForm {
  
  shouldShowModal() {
    return this.props.newTaskInProgress;
  }
  
  label() {
    return "Add New Task!";
  }
  
  icon() {
    return (<i className="fa fa-plus-circle"></i>);
  }
  
  task() {
    return this.props.newTask;
  }
  
  handleClass() {
    return 'green';
  }
  
  update(e) {
    var value;
    
    if(e.target.type == 'checkbox') {
      value = e.target.checked;
    } else {
      value = e.target.value
    }
    
    store.fire('NEW_TASK_UPDATED', {[e.target.name]: value})
  }
  
  updateTags(tag) {
    store.fire('NEW_TASK_UPDATED', {tag_id: tag.value})
  }
  
  submit(e) {
    e.preventDefault();
    
    store.fire('CREATE_TASK');
  }
  
}
