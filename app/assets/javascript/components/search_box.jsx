import React from 'react';
import classnames from 'classnames';
import {store} from 'store'
import Tag from 'components/tag';
import {sfxManager} from 'sfx_manager'
import { Modal, ModalHeader, ModalBody } from 'reactstrap';
import Wade from 'wade';
import isEqual from 'lodash.isequal'

export default class SearchBox extends React.Component {
  constructor(props) {
    super(props);
    
    if(this.props.tasks.length == 0) {
      this.initialState = {
        searchTerm: "",
        results: this.props.tasks.slice(0, this.maxResults),
        selectedResultId: null,
        selectedResultIndex: null
      };
    } else {
      this.initialState = {
        searchTerm: "",
        results: this.props.tasks.slice(0, this.maxResults),
        selectedResultId: this.props.tasks[0].id,
        selectedResultIndex: 0
      };
      
    }
    
    this.maxResults = 14;
    
    this.state = Object.assign({}, this.initialState);
    this.search = this.search.bind(this);
    this.handleInputKeyDown = this.handleInputKeyDown.bind(this);
    this.handleKeyDown = this.handleKeyDown.bind(this);
    this.handleKeyUp = this.handleKeyUp.bind(this);
    this.selectPrevResult = this.selectPrevResult.bind(this);
    this.selectNextResult = this.selectNextResult.bind(this);
    this.completeTask = this.completeTask.bind(this);
    this.reset = this.reset.bind(this);
    this.click = this.click.bind(this);
    
    this.initWade();
  }
  
  componentDidUpdate(prevProps) {
    if (!isEqual(this.props.tasks, prevProps.tasks)) {
      this.initWade();
    }
  }
  
  initWade() {
    this.wade = Wade(this.props.tasks.map((task)=> task.name));
  }
  
  shouldShowModal() {
    return this.props.searchInProgress;
  }
  
  close(e) {
    if(e !== undefined) {
      e.preventDefault();
    }
  
    store.fire('SEARCH_FINISHED');
    
    return false;
  }
  
  search(e) {
    var term = e.target.value;
    var results = this.wade(term).
      filter((result)=> result.score == 1).
      map((result)=> this.props.tasks[result.index]).
      slice(0, this.maxResults);
      
    var newState = {
      results: results,
      searchTerm: term
    }
    
    var resultsFound = results.length > 0;
    var emptyQuery = term == "";
    
    if(emptyQuery){
      newState.results = this.props.tasks.slice(0, this.maxResults);
      newState.selectedResultId = this.props.tasks[0].id;
      newState.selectedResultIndex = 0
    } else if(resultsFound) {
      newState.selectedResultId = results[0].id;
      newState.selectedResultIndex = 0
    }
    
    this.setState(newState);
  }
  
  reset() {
    this.setState(this.initialState);
  }
  
  handleKeyDown(e) {
    if(e.key == "ArrowUp") {
      this.selectPrevResult()
    } else if(e.key == "ArrowDown") {
      this.selectNextResult()
    }
  }
  
  handleInputKeyDown(e) {
    if(e.key == 'Escape') {
      this.close();
    }
  }
  
  handleKeyUp(e) {
    if(e.key == "Enter") {
      this.completeTask();
    }
  }
  
  completeTask() {
    var task = this.props.tasks.find((task)=> task.id == this.state.selectedResultId);
    store.completeTask(task);
    store.fire('TASK_COMPLETED_FROM_SEARCH', task)
    sfxManager.beep();
  }
  
  selectPrevResult() {
    var newIndex = this.state.selectedResultIndex - 1;
    var newId = this.state.results[newIndex].id;
    
    this.setState({
      selectedResultId: newId,
      selectedResultIndex: newIndex
    })
  }
  
  selectNextResult() {
    var newIndex = this.state.selectedResultIndex + 1;
    var newId = this.state.results[newIndex].id;
    
    this.setState({
      selectedResultId: newId,
      selectedResultIndex: newIndex
    });
  }
  
  click(e) {
    var newIndex = Array.from(e.currentTarget.parentNode.children).indexOf(e.currentTarget);
    var newId = this.state.results[newIndex].id;
    
    this.setState({
      selectedResultId: newId,
      selectedResultIndex: newIndex
    }, ()=> window.setTimeout(this.completeTask, 150));
  }
  
  render(){
    if(this.props.tasks.length == 0) {
      return null;
    }
    
    var results = this.state.results;
    var resultsFound = this.state.results !== undefined;
    if(!resultsFound) results = [];
    
    const resultRows = results.map((result)=> {
      if(result.id == this.state.selectedResultId) {
        return (
          <p key={result.id} onClick={this.click} className="pointer result-row d-flex justify-content-between selected-result">
            <span className="justify-content-start">{result.name}</span>
            <Tag {...this.props} tag={this.props.tags[result.tag_id]} />
          </p>
        );
      } else {
        return (
          <p key={result.id} onClick={this.click} className="pointer result-row d-flex justify-content-between">
            <span className="justify-content-start">{result.name}</span>
            <Tag {...this.props} tag={this.props.tags[result.tag_id]} />
          </p>
        );
      }
    })
    
    return (
      <Modal
        isOpen={this.shouldShowModal()}
        keyboard={true}
        onKeyDown={this.handleKeyDown}
        onKeyUp={this.handleKeyUp}
        toggle={this.close}
        onOpened={this.reset}
        modalTransition={{timeout: 50}}
        backdropTransition={{timeout: 0}}
        modalClassName="search-box-modal"
      >
        <ModalBody>
          <input
            type="text"
            autoComplete="false"
            placeholder="search..."
            name="search-term"
            autoFocus="true"
            className="search"
            onChange={this.search}
            onKeyDown={this.handleInputKeyDown}
            value={this.state.searchTerm} 
          />
          <div className="search-results">
            {resultRows}
          </div>
        </ModalBody>
      </Modal>
    )
  }
}
