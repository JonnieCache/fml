import React from 'react'
import {store} from 'store'
import ColorPicker from 'coloreact';
import { Modal, ModalHeader, ModalBody } from 'reactstrap';

export default class TagForm extends React.Component {
  close(e) {
    if(e !== undefined) {
      e.preventDefault();
    }
    
    store.fire('EDITING_FINISHED');
    
    return false;
  }
  
  render(){
    return (
      <Modal isOpen={this.shouldShowModal()} toggle={this.close}>
        <ModalHeader toggle={this.props.closeModals}>
          {this.icon()}
          {this.label()}
        </ModalHeader>
        <ModalBody>
          <form onSubmit={this.submit}>
            <div className="form-group row">
              <label className="col-2 col-form-label" htmlFor="tag-name">Name</label>
              <div className="col-10">
                <input onChange={this.update} value={this.tag().name} name="name" className="form-control" id="tag-name" type="text" />
              </div>
            </div>
            
            <div className="form-group row">
              <label className="col-2 col-form-label" htmlFor="tag-goal_per_week">Goal (per week)</label>
              <div className="col-10">
                <input onChange={this.update} value={this.tag().goal_per_week} name="goal_per_week" className="form-control" id="tag-goal_per_week" type="text" />
              </div>
            </div>
            
            <div className="form-group row">
              <label className="col-2 col-form-label" htmlFor="tag-show_meter">Show Meter?</label>
              <div className="col-10">
                <input onChange={this.update} checked={this.tag().show_meter} name="show_meter" id="task-show_meter" style={{verticalAlign: "bottom"}} type="checkbox" />
              </div>
            </div>
            
            <div className="form-group row">
              <label className="col-2 col-form-label" htmlFor="tag-color">Colour</label>
              <div className="col-10">
                <ColorPicker
                  opacity={false}
                  color={this.tag().color}
                  onChange={this.updateColor}
                  style={{height: '100px'}}
                />
              </div>
            </div>
            
            <div className="row">
              <div className="col-12 form-buttons">
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