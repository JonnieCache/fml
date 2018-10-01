import React from 'react'
import {store} from 'store'

export default class Tag extends React.Component {
  constructor(props) {
    super(props);
    
    this.editTag = this.editTag.bind(this);
  }
  
  editTag() {
    store.fire('TAG_EDIT_START', this.props.tag);
  }
  
  render() {
    return (
      <span
        key={this.props.tag.id}
        onClick={this.editTag}
        className="tag justify-content-end"
        style={{backgroundColor: "#"+this.props.tag.color}}
      >
        {this.props.tag.name}
      </span>
    );
  }
}
