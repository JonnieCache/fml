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
        
    store.getState();
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
