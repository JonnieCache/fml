import React from 'react'
import App from 'components/app'
import mapValues from 'lodash.mapvalues'
import {store} from 'store'

export default class Controller extends React.Component {
  constructor(props) {
    super(props);
    
    this.state = {
      newTask: {},
      taskBeingEdited: {},
      tagBeingEdited: {},
      searchInProgress: false,
      taskView: window.localStorage.getItem('taskView') || 'cards'
    };
    Object.assign(this.state.newTask, store.emptyTask);
  }
  
  componentDidMount() {
    store.on('STATE_UPDATED', (update)=> {
      // update.tasks = update.tasks.filter(task=> task.state == 'incomplete').map(this._parseTask);
      update.tasks = update.tasks.map(this._parseTask);
      update.completions = mapValues(update.completions, this._parseCompletion);
      this.setState(update);
    });
    
    store.on('TASK_EDIT_START', (task)=> {
      this.setState((oldState)=> {
        Object.assign(oldState.taskBeingEdited, task);
        oldState.editTaskInProgress = true;
        oldState.searchInProgress = false;
        
        return oldState;
      });
    });
    
    store.on('EDITED_TASK_UPDATED', (update)=> {
      this.setState((oldState)=>{
        Object.assign(oldState.taskBeingEdited, update);
        
        return oldState;
      });
    });
    
    store.on('UPDATE_TASK', ()=> store.updateTask(this.state.taskBeingEdited));
    
    store.on('TASK_UPDATED', (update)=> {
      this.setState((oldState)=> {
        this._replaceTasks(oldState.tasks, update.tasks);
        Object.assign(oldState.tags, update.tags);
        
        return oldState;
      }, ()=> store.fire('EDITING_FINISHED'));
    });
    
    store.on('NEW_TASK_START', (task)=> this.setState({newTaskInProgress: true}));
    
    store.on('NEW_TASK_UPDATED', (update)=> {
      this.setState((oldState)=>{
        Object.assign(oldState.newTask, update);
        
        return oldState;
      });
    });
    
    store.on('CREATE_TASK', ()=> store.createTask(this.state.newTask));
    
    store.on('TASK_CREATED', (update)=> {
      this.setState((oldState)=> {
        return {
          completions: Object.assign(oldState.completions, update.completions),
          tags: Object.assign(oldState.tags, update.tags),
          tasks: update.tasks.map(this._parseTask).concat(oldState.tasks)
        };
      }, ()=> store.fire('EDITING_FINISHED'));
    });
    
    store.on('TASK_COMPLETED', (update)=> {
      this.setState((oldState)=> {
        this._replaceTasks(oldState.tasks, update.tasks);
        Object.assign(oldState.completions, mapValues(update.completions, this._parseCompletion));
        tags: Object.assign(oldState.tags, update.tags),
        oldState.combo = update.combo;
        oldState.score = update.score;
        oldState.searchInProgress = false;
        
        return oldState;
      });
    });
    
    store.on('TAG_EDIT_START', (tag)=> {
      this.setState({
        tagBeingEdited: Object.assign({}, tag),
        searchInProgress: false,
        editTagInProgress: true
      })
    });
    
    store.on('EDITED_TAG_UPDATED', (update)=> {
      this.setState((oldState)=>{
        Object.assign(oldState.tagBeingEdited, update);
        
        return oldState;
      });
    });
    
    store.on('TAG_UPDATED', (update)=> {      
      this.setState((oldState)=> {
        Object.assign(oldState.tags, update.tags);
        
        return oldState;
      }, ()=> store.fire('EDITING_FINISHED'));
    });

    store.on('EDITING_FINISHED', ()=> {
      var newState = {
        newTaskInProgress: false,
        editTaskInProgress: false,
        editTagInProgress: false,
        newTask: {}
      };
      Object.assign(newState.newTask, store.emptyTask);
      
      this.setState(newState);
    });
    
    store.on('SEARCH_START', ()=> {
      if(this.state.searchInProgress) {
        store.fire('SEARCH_FINISHED');
      }
      
      var newState = {
        newTaskInProgress: false,
        editTaskInProgress: false,
        editTagInProgress: false,
        searchInProgress: true,
        newTask: {}
      };
      Object.assign(newState.newTask, store.emptyTask);
      
      this.setState(newState);
    });
    
    store.on('SEARCH_FINISHED', ()=> this.setState({searchInProgress: false}));
    
    store.on('TOGGLE_TASK_VIEW', ()=> {
      this.setState(function(state){
        if(state.taskView == 'cards') {
          window.localStorage.setItem('taskView', 'rows')
          state.taskView = 'rows'
        } else {
          window.localStorage.setItem('taskView', 'cards')
          state.taskView = 'cards'
        }
        
        return state
      });
    });
    
    store.on('SORT_TASKS', (sortData)=> {
      var src = sortData.source.index;
      var dest = sortData.destination.index;
      
      if(sortData.destination.droppableId == 'task-rows-nice1' && this.state.nomination.essential_task_id) {
        dest++;
      }
      if(sortData.destination.droppableId == 'task-rows-nice2') {
        if(this.state.nomination.essential_task_id) dest++;
        if(this.state.nomination.nice_task_1_id)    dest++;
      }
      if(sortData.destination.droppableId == 'task-rows') {
        if(this.state.nomination.essential_task_id) dest++;
        if(this.state.nomination.nice_task_1_id)    dest++;
        if(this.state.nomination.nice_task_2_id)    dest++;
      }
      
      if(sortData.destination.droppableId == 'task-rows-nice1' && this.state.nomination.essential_task_id) {
        src++;
      }
      if(sortData.destination.droppableId == 'task-rows-nice2') {
        if(this.state.nomination.essential_task_id) src++;
        if(this.state.nomination.nice_task_1_id)    src++;
      }
      if(sortData.destination.droppableId == 'task-rows') {
        if(this.state.nomination.essential_task_id) src++;
        if(this.state.nomination.nice_task_1_id)    src++;
        if(this.state.nomination.nice_task_2_id)    src++;
      }
      
      const newTasks = this._reorder(
        this.state.tasks,
        Math.min(src, this.state.tasks.length-1),
        Math.min(dest, this.state.tasks.length-1)
      );
      
      
      var essentialTaskId;
      var niceTask1Id;
      var niceTask2Id;
      
      if(sortData.destination.droppableId == 'task-rows-essential') {
        essentialTaskId = sortData.draggableId;
      } else if(sortData.destination.droppableId == 'task-rows-nice1') {
        niceTask1Id = sortData.draggableId;
      } else if(sortData.destination.droppableId == 'task-rows-nice2') {
        niceTask2Id = sortData.draggableId;
      }
      
      if(sortData.source.droppableId == 'task-rows-essential') {
        essentialTaskId = false;
      } else if(sortData.source.droppableId == 'task-rows-nice1') {
        niceTask1Id = false;
      } else if(sortData.source.droppableId == 'task-rows-nice2') {
        niceTask2Id = false;
      }
      
      var update = {
        taskOrder: newTasks.map((t)=> t.id),
        essentialTaskId: essentialTaskId,
        niceTask1Id: niceTask1Id,
        niceTask2Id: niceTask2Id
      }
      
      this.setState(function(newState){
        newState.tasks = newTasks;
        newState.user.task_order = update.taskOrder;
        
        if(essentialTaskId) {
          newState.nomination.essential_task_id = essentialTaskId;
        } else if(essentialTaskId === false) {
          delete newState.nomination.essential_task_id;
        }
        if(niceTask1Id) {
          newState.nomination.nice_task_1_id = niceTask1Id;
        } else if(niceTask1Id === false) {
          delete newState.nomination.nice_task_1_id;
        }
        if(niceTask2Id) {
          newState.nomination.nice_task_2_id = niceTask2Id;
        } else if(niceTask2Id === false) {
          delete newState.nomination.nice_task_2_id;
        }
        
        return newState;
      });
      
      store.sortTasks(update);
    });
        
    store.getState();
  }
  
  _reorder(list, startIndex, endIndex) {
    const result = Array.from(list);
    const [removed] = result.splice(startIndex, 1);
    result.splice(endIndex, 0, removed);

    return result;
  }
  
  _replaceTasks(oldTasks, newTasks) {
    for(let task of newTasks) {
      let index = oldTasks.findIndex((thisTask) => thisTask.id == task.id);
      oldTasks[index] = this._parseTask(task);
    }
  }
  
  _parseTask(rawTask) {
    var task = Object.assign({}, rawTask);
    
    task.created_at        = new Date(task.created_at);
    task.updated_at        = new Date(task.updated_at);
    task.last_completed_at = new Date(task.last_completed_at);
    task.last_nominated_at = new Date(task.last_nominated_at);
    
    return task;
  }
  
  _parseCompletion(rawCompletion) {
    var completion = Object.assign({}, rawCompletion);
    
    completion.created_at = new Date(completion.created_at);
    completion.updated_at = new Date(completion.updated_at);
    
    return completion;
  }
  
  render() {
    return (<App {...this.state} />)
  }
}
