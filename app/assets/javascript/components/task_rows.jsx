import React from 'react'
import TaskRow from 'components/task_row'

export default class TaskRows extends React.Component {
  
  render(){
    var rows = this.props.tasks.
      filter(task=> task.state == 'incomplete').
      map(task => <TaskRow {...this.props} task={task} key={task.id} />);
    
    return (
      <div className="task-rows" onKeyUp={this.onKeyUp}>
        {rows}
      </div>
    )
  }
}
