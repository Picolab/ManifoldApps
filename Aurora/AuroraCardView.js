import React, { Component } from 'react';
import { Button, ListGroup, ListGroupItem } from 'reactstrap';

import 'rc-slider/assets/index.css';
import 'rc-tooltip/assets/bootstrap.css';

import Tooltip from 'rc-tooltip';
import Slider from 'rc-slider';

import './Aurora.css';

const Handle = Slider.Handle;

const handle = (props) => {
  const { value, dragging, index, ...restProps } = props;
  return (
    <Tooltip
      prefixCls="rc-slider-tooltip"
      overlay={value}
      visible={dragging}
      placement="top"
      key={index}
    >
      <Handle value={value} {...restProps} />
    </Tooltip>
  );
};

export default class AuroraCardView extends Component {

  constructor(props) {
    super(props);
    this.state = {
      connected: false,
      triedLoading: false
    }

    this.connect = this.connect.bind(this);
    this.turnOn = this.turnOn.bind(this);
    this.turnOff = this.turnOff.bind(this);
    this.hueHandle = this.hueHandle.bind(this);
    this.saturationHandle = this.saturationHandle.bind(this);
    this.brightnessHandle = this.brightnessHandle.bind(this);
    this.listEffects = this.listEffects.bind(this);
    this.selectEffect = this.selectEffect.bind(this);
  }

  componentDidMount() {
    this.checkConnection();
  }

  connect(host, auth) {
    let promise = this.props.signalEvent({
      domain: "aurora_app",
      type: "connection_info",
      attrs : { host: host, auth: auth }
    })

    promise.then(() => {
      this.checkConnection();
    })
  }

  checkConnection() {
    let promise = this.props.manifoldQuery({
      rid: "io.picolabs.aurora_app",
      funcName: "connectionInfo"
    });

    promise.then((resp) => {
      if (resp.data.host && resp.data.auth) {
        let promise2 = this.props.manifoldQuery({
          rid: "io.picolabs.aurora_app",
          funcName: "getData"
        });

        promise2.then((resp2) => {
          if(resp2.data.isOn) {
            let newState = resp2.data;
            newState.connected = true;
            newState.triedLoading = true;
            this.setState(newState);
          }
        })
      }
      else this.setState({triedLoading: true})
    })
  }

  onButtonColor() {
    if(this.state.isOn.value) return "primary"
    else return "secondary";
  }
  offButtonColor() {
    if(!this.state.isOn.value) return "primary"
    else return "secondary";
  }

  turnOn() {
    let promise = this.props.signalEvent({
      domain: "aurora_app",
      type: "turn_on"
    });
    promise.then(() => {
      this.setState({isOn : {value : true}})
    });
  }

  turnOff() {
    let promise = this.props.signalEvent({
      domain: "aurora_app",
      type: "turn_off"
    });
    promise.then(() => {
      this.setState({isOn : {value : false}})
    });
  }

  hueHandle(value) {
    let promise = this.props.signalEvent({
      domain: "aurora_app",
      type: "set_hue",
      attrs: {value}
    })

    promise.then(() => {
      let promise2 = this.props.manifoldQuery({
        rid: "io.picolabs.aurora_app",
        funcName: "getHue"
      });
      promise2.then((resp) => {
        if(resp.data) this.setState({hue: resp.data, currentEffect: "*Solid*"})
      })
    });
  }

  saturationHandle(value) {
    let promise = this.props.signalEvent({
      domain: "aurora_app",
      type: "set_saturation",
      attrs: {value, currentEffect: "*Solid*"}
    })

    promise.then(() => {
      let promise2 = this.props.manifoldQuery({
        rid: "io.picolabs.aurora_app",
        funcName: "getSaturation"
      });
      promise2.then((resp) => {
        if(resp.data) this.setState({saturation: resp.data, currentEffect: "*Solid*"})
      })
    });
  }

  brightnessHandle(value) {
    let promise = this.props.signalEvent({
      domain: "aurora_app",
      type: "set_brightness",
      attrs: {value}
    })

    promise.then(() => {
      let promise2 = this.props.manifoldQuery({
        rid: "io.picolabs.aurora_app",
        funcName: "getSaturation"
      });
      promise2.then((resp) => {
        if(resp.data) this.setState({saturation: resp.data})
      })
    });
  }

  selectEffect(effect) {
    return () => {
      let promise = this.props.signalEvent({
        domain: "aurora_app",
        type: "effect",
        attrs: {effect}
      });

      promise.then(() => {
        let promise2 = this.props.manifoldQuery({
          rid: "io.picolabs.aurora_app",
          funcName: "currentEffect"
        });
        promise2.then((resp) => {
          if(resp.data) this.setState({currentEffect: resp.data})
        })
      });
    }
  }

  listEffects() {
    var toRet = [];
    this.state.allEffects.forEach((item) => {
      toRet.push(<ListGroupItem className="effectList" id={item} style={this.isSelected(item)} onClick={this.selectEffect(item)}>{item}</ListGroupItem>)
    });
    return toRet;
  }

  isSelected(cur) {
    if(cur === this.state.currentEffect) return {backgroundColor: '#20A8D8', color: '#ffffff'};
    else return {};
  }

  controlPanel() {
    return (
      <div>
        <h5>Hue:</h5>
        <Slider min={this.state.hue.min} max={this.state.hue.max} defaultValue={this.state.hue.value} onAfterChange={this.hueHandle} handle={handle} />
        <br />

        <h5>Saturation:</h5>
        <Slider min={this.state.saturation.min} max={this.state.saturation.max} defaultValue={this.state.saturation.value} onAfterChange={this.saturationHandle} handle={handle} />
        <br />

        <h5>Brightness:</h5>
        <Slider min={this.state.brightness.min} max={this.state.brightness.max} defaultValue={this.state.brightness.value} onAfterChange={this.brightnessHandle} handle={handle} />
        <br />

        <h5>Effects:</h5>
        <ListGroup>
          {this.listEffects()}
        </ListGroup>
        <br />

        <h5>Power:</h5>
        <Button color={this.onButtonColor()} onClick={this.turnOn}>On</Button>
        <Button color={this.offButtonColor()} onClick={this.turnOff}>Off</Button>
      </div>
    )
  }

  render() {
    return(
      <div style={{paddingBottom: "20px"}}>
        {(!this.state.connected && this.state.triedLoading) && <p>Unable to connect to Aurora</p>}
        {(!this.state.connected && !this.state.triedLoading) && <p>Loading...</p>}
        {this.state.connected && this.controlPanel()}
      </div>
    );
  }

}
