import React from 'react'
import TaskRow from 'components/task_row'
import remove from 'lodash.remove'
import {store} from 'store'

// import {SortableContainer, SortableElement, arrayMove} from 'react-sortable-hoc';
import { DragDropContext, Droppable, Draggable } from 'react-beautiful-dnd';

export default class TaskRows extends React.Component {
  
  constructor(props) {
    super(props);
    
    this.makeDraggable = this.makeDraggable.bind(this);
  }
  
  onDragEnd(result) {
    if (!result.destination) {
      return;
    }
    
    store.fire('SORT_TASKS', result);
  }
  
  makeDraggable(task, index) {
    return (
      <Draggable key={task.id} index={index} draggableId={task.id}>
        {(provided, snapshot) => (
          <div ref={provided.innerRef} {...provided.draggableProps} {...provided.dragHandleProps}>
            <TaskRow {...this.props} task={task} />
          </div>
        )}
      </Draggable>
    );
  }
  
  render(){
    const tasks = this.props.tasks.slice(0);
    const essentialTask = this.props.nomination && remove(tasks, (t)=> t.id == this.props.nomination.essential_task_id)[0];
    const niceTask1 = this.props.nomination && remove(tasks, (t)=> t.id == this.props.nomination.nice_task_1_id)[0];
    const niceTask2 = this.props.nomination && remove(tasks, (t)=> t.id == this.props.nomination.nice_task_2_id)[0];
    
    const rows = tasks.map(this.makeDraggable);
    
    return (
      <DragDropContext onDragEnd={this.onDragEnd}>
        <Droppable droppableId="task-rows-essential">
          {(provided, snapshot) => (
            <div ref={provided.innerRef} {...provided.droppableProps}  className="task-rows task-rows-essential" onKeyUp={this.onKeyUp}>
              {essentialTask && this.makeDraggable(essentialTask, 0)}
              {provided.placeholder}
            </div>
          )}
        </Droppable>
        <hr />
        <Droppable droppableId="task-rows-nice1">
          {(provided, snapshot) => (
            <div ref={provided.innerRef} {...provided.droppableProps}  className="task-rows task-rows-nice1" onKeyUp={this.onKeyUp}>
              {niceTask1 && this.makeDraggable(niceTask1, 0)}
              {provided.placeholder}
            </div>
          )}
        </Droppable>
        <hr />
        <Droppable droppableId="task-rows-nice2">
          {(provided, snapshot) => (
            <div ref={provided.innerRef} {...provided.droppableProps}  className="task-rows task-rows-nice2" onKeyUp={this.onKeyUp}>
              {niceTask2 && this.makeDraggable(niceTask2, 0)}
              {provided.placeholder}
            </div>
          )}
        </Droppable>
        <hr />
        <Droppable droppableId="task-rows">
          {(provided, snapshot) => (
            <div ref={provided.innerRef} {...provided.droppableProps}  className="task-rows task-rows-rest" onKeyUp={this.onKeyUp}>
              {rows}
              {provided.placeholder}
            </div>
          )}
        </Droppable>
      </DragDropContext>
    )
  }
}
