import React from 'react'
import Progress from 'react-progressbar';
import {store} from 'store'
import partial from 'lodash.partial';

export default class NeedsMeters extends React.Component {
  edit(tag) {
    store.editTag(tag);
  }
  
  render(){
    var meters = [];
    
    for (var tagId in this.props.tags) {
      var tag =  this.props.tags[tagId];
      if(!tag.show_meter){
        continue;
      }
      
      meters.push(
        <div className="meter-container" key={tag.id}>
          <span onClick={partial(this.edit, tag)} className="meter-label">{tag.name}:</span>
          <Progress completed={tag.need * 100} color={"#"+tag.color} />
        </div>
      );
    };
    
    return (
      <div className="media-body" id="needs-meters">{meters}</div>
    )
  }
}
