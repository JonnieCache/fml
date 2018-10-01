import React from 'react'
import {store} from 'store'
import TaskForm from 'components/task_form'

export default class EditTaskForm extends TaskForm {
  constructor() {
    super()
    
    this.submit = (e) => {
      e.preventDefault();

      store.fire('UPDATE_TASK');
    }
  }
  
  shouldShowModal() {
    return this.props.editTaskInProgress;
  }
  
  label() {
    return `Editing Task "${this.task().name}"`;
  }
  
  icon() {
    return (<i className="fa fa-pencil"></i>);
  }
  
  task() {
    return this.props.taskBeingEdited;
  }
  
  handleClass() {
    return 'blue';
  }
  
  update(e){
    var value;
    
    if(e.target.type == 'checkbox') {
      value = e.target.checked;
    } else {
      value = e.target.value
    }
    
    store.fire('EDITED_TASK_UPDATED', {[e.target.name]: value});
  }
  
  updateTags(tag) {
    store.fire('EDITED_TASK_UPDATED', {tag_id: tag.value});
  }
  
}
