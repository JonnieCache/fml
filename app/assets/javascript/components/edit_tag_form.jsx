import React from 'react'
import {store} from 'store'
import TagForm from 'components/tag_form'

export default class EditTagForm extends TagForm {
  constructor() {
    super()
    
    this.submit = (e) => {
      e.preventDefault();
      
      store.updateTag(this.props.tagBeingEdited);
    }
  }
  
  shouldShowModal() {
    return this.props.editTagInProgress;
  }
  
  label() {
    return `Editing Tag "${this.tag().name}"`;
  }
  
  icon() {
    return (<i className="fa fa-pencil"></i>);
  }
  
  tag() {
    return this.props.tagBeingEdited;
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
    
    store.fire('EDITED_TAG_UPDATED', {[e.target.name]: value});
  }
  
  updateColor(u){
    store.fire('EDITED_TAG_UPDATED', {color: u.hexString.substring(1)});
  }
  
}
