
var React = require('react');
var {
  PropTypes,
} = React;

var ReactNative = require('react-native');
var {
  View,
  NativeMethodsMixin,
  requireNativeComponent,
  StyleSheet,
} = ReactNative;

var resolveAssetSource = require('react-native/Libraries/Image/resolveAssetSource');

var MapImage = React.createClass({
  mixins: [NativeMethodsMixin],

  propTypes: {
    ...View.propTypes,

    /**
     * The region to be displayed by the map.
     *
     * The region is defined by the center coordinates and the span of
     * coordinates to display.
     */
    region: PropTypes.shape({
      /**
       * Coordinates for the center of the map.
       */
      latitude: PropTypes.number.isRequired,
      longitude: PropTypes.number.isRequired,

      /**
       * Difference between the minimun and the maximum latitude/longitude
       * to be displayed.
       */
      latitudeDelta: PropTypes.number.isRequired,
      longitudeDelta: PropTypes.number.isRequired,
    }).isRequired,

    /**
     * A custom image to be used as the marker's icon. Only local image resources are allowed to be
     * used.
     */
    source: PropTypes.any,

    /**
     * Callback that is called when the user presses on the circle
     */
    onPress: PropTypes.func
  },

  getDefaultProps: function() {
    return {
    };
  },

  _onPress: function(e) {
    this.props.onPress && this.props.onPress(e);
  },

  shouldComponentUpdate: function(nextProps) {
    return (this.props.source !== nextProps.source) ||
      (this.props.region !== nextProps.region);
  },

  render: function() {
    var source = undefined;
    if (this.props.source) {
      source = resolveAssetSource(this.props.source) || {};
      source = source.uri;
    }
    return (
      <AIRMapImage
        {...this.props}
        source={source}
        onPress={this._onPress}
      />
    );
  }
});

var AIRMapImage = requireNativeComponent('AIRMapImage', MapImage);

module.exports = MapImage;
