import React from 'react'
import TaskCard from 'components/task_card'

export default class TaskCards extends React.Component {
  
  onKeyUp(e){
  }
  
  render(){
    var cards = this.props.tasks.
      filter(task=> task.state == 'incomplete').
      map(task => <TaskCard {...this.props} task={task} key={task.id} />);
    
    return (
      <div className="card-columns task-cards" onKeyUp={this.onKeyUp}>
        {cards}
      </div>
    )
  }
}
