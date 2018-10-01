import BigCalendar from 'react-big-calendar'
import React from 'react'
import moment from 'moment';
import find from 'lodash.find';
import {store} from 'store'

export default class ScoreBoard extends React.Component {
  constructor(props) {
    super(props);
    
    BigCalendar.momentLocalizer(moment);
    
    this.events = this.props.completions.map((completion)=> {
      var task = find(this.props.tasks, (task)=> {
        return task.id == completion.task_id;
      });
      return {
        'title': task.name,
        // 'allDay': true,
        'start': completion.created_at,
        'end': completion.created_at
      }
    });
  }
  
  render() {
    return (
      <div className="scoreboard">
        <BigCalendar
          events={this.events}
          toolbar={false}
          defaultDate={new Date()}
        />
      </div>
    )
  }
}