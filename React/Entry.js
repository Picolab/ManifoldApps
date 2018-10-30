import React, { Component } from 'react';
import { ListGroupItem, Collapse, Button, Form, FormGroup, Input } from 'reactstrap';
import './Journal.css';

export default class Entry extends Component {

  constructor(props) {
    super(props);
    this.state = {
      collapse: false,
      content: ""
    }
    this.deleteEntry = this.deleteEntry.bind(this);
    this.editToggle = this.editToggle.bind(this);
    this.onChange = this.onChange.bind(this);
    this.submit = this.submit.bind(this);
  }


  deleteEntry() {
    const promise = this.props.signalEvent({
      domain : "journal",
      type : "delete_entry",
      attrs : { timestamp : this.props.entry.timestamp }
    })
    promise.then(() => {
      this.props.retrieveEntries();
    })
  }

  editToggle() {
    this.setState({
      collapse: !this.state.collapse
    })
  }

  onChange(stateKey) {
    return (event) => {
      let value = event.target.value
      this.setState({
        [stateKey]: value
      })
    }
  }

  submit(e) {
    e.preventDefault();

    const promise = this.props.signalEvent({
      domain : "journal",
      type : "edit_entry",
      attrs : {
        timestamp : this.props.entry.timestamp,
        newContent : this.state.content
      }
    })
    promise.then(() => {
      this.props.retrieveEntries();
      this.setState({
        collapse : false
      })
    })
  }

  render() {
    const { entry } = this.props;
    return (
      <div>
        <ListGroupItem>
          <i id={"delete" + entry.timestamp} className="fa fa-trash float-right fa-lg manifoldDropdown" onClick={this.deleteEntry}/>
          <i id={"edit" + entry.timestamp} className="fa fa-edit float-right fa-lg manifoldDropdown" onClick={this.editToggle} />
          <h5 className="title">{entry.title}</h5>
          <p className="timestamp">{entry.timestamp}</p>
          <p className="content">{entry.content}</p>

          <Collapse isOpen={this.state.collapse}>
            <Form onSubmit={this.submit}>
              <FormGroup>
                New content:
                <Input type="textarea" name="message" id="Message" style={{height: '75px'}} value={this.state.content} onChange={this.onChange('content')} />
              </FormGroup>
              <Button color="primary">Update</Button>
            </Form>
          </Collapse>

        </ListGroupItem>
      </div>
    );
  }

}
