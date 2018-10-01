import React from 'react'
import { Creatable } from 'react-select';
import {store} from 'store'
import { Modal, ModalHeader, ModalBody } from 'reactstrap';

export default class TaskForm extends React.Component {
  close(e) {
    if(e !== undefined) {
      e.preventDefault();
    }
    
    store.fire('EDITING_FINISHED');
    
    return false;
  }
  
  render(){
    var allTags = [];
    
    for (var tagId in this.props.tags) {
      var tag =  this.props.tags[tagId];
      
      allTags.push({value: tag.id, label: tag.name});
    }
    
    allTags.sort(function(a, b) {
      var labelA = a.label.toUpperCase();
      var labelB = b.label.toUpperCase();
      if (labelA < labelB) {
        return -1;
      }
      if (labelA > labelB) {
        return 1;
      }

      return 0;
    });
    
    var tag = this.props.tags[this.task().tag_id];
    if(tag !== undefined){
      tag = {value: tag.id, label: tag.name};
    } else {
      // fake value to be inserted by the server and given a real id
      tag = {value: this.task().tag_id, label: this.task().tag_id};
    }
    
    
    return (
      <Modal isOpen={this.shouldShowModal()} toggle={this.close} keyboard={true}>
        <ModalHeader toggle={this.props.closeModals}>
          {this.icon()}
          <span className="media-body align-self-start">{this.label()}</span>
        </ModalHeader>
        <ModalBody>
          <form onSubmit={this.submit}>
            <div className="form-group row">
              <label className="col-4 col-form-label" htmlFor="task-name">Name</label>
              <div className="col-8">
                <input onChange={this.update} value={this.task().name} name="name" className="form-control" id="task-name" type="text" />
              </div>
            </div>
            
            <div className="form-group row">
              <label className="col-4 col-form-label" htmlFor="task-value">Value</label>
              <div className="col-8">
                <input onChange={this.update} value={this.task().value} name="value" className="form-control" id="task-value" min="0" step="1" type="number" />
              </div>
            </div>
            
            <div className="form-group row">
              <label className="col-4 col-form-label" htmlFor="task-recurring">Recurring?</label>
              <div className="col-8">
                <input onChange={this.update} checked={this.task().recurring} name="recurring" id="task-recurring" style={{verticalAlign: "bottom"}} type="checkbox" />
              </div>
            </div>
            
            <div className="form-group row">
              <label className="col-4 col-form-label" htmlFor="task-tag_id">Tag</label>
              <div className="col-8 select-tags">
                <Creatable
                  multi={false}
                  name="tag_id"
                  id="task-tag_id"
                  options={allTags}
                  value={tag}
                  onChange={this.updateTags}
                  clearable={false}
                  backspaceRemoves={false}
                  className="menu-outer-top"
                  scrollMenuIntoView={false}
                />
              </div>
            </div>
            
            <div className="row form-buttons">
              <div className="col-12">
                <button style={{marginRight: '1rem'}} onClick={this.close} className="btn btn-default">Cancel</button>
                <button className="btn btn-success">Save</button>
              </div>
            </div>
          </form>
        </ModalBody>
      </Modal>
    )
  }
}
