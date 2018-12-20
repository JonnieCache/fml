import React from 'react'
import TaskRow from 'components/task_row'

import {SortableContainer, SortableElement, arrayMove} from 'react-sortable-hoc';

export default class TaskRows extends React.Component {
  
  onSortEnd(oldIndex, newIndex) {
    debugger;
  }
  
  render(){
    const SortableRow = SortableElement(({props, task}) =>
      <TaskRow {...this.props} task={task} key={task.id} />        
    );
    
    // const SortableList = SortableContainer(({rows}) => {
    //   return (
    //     <div className="task-rows" onKeyUp={this.onKeyUp}>
    //       {rows}
    //     </div>
    // });
      
    const SortableList = SortableContainer(({tasks}) => {
      var onSortEnd = this.onSortEnd;
      const rows = tasks.
        filter(task=> task.state == 'incomplete').
        map((task, index) => {
          return (
            <SortableRow task={task} index={index} key={task.id} onSortEnd={onSortEnd} />
          );
        });
      
      return (
        <div className="task-rows" onKeyUp={this.onKeyUp}>
          {rows}
        </div>
      );
    });
    
    return (
      <SortableList tasks={this.props.tasks}/>
    )
  }
}
