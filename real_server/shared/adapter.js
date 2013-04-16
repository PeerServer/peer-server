/* Setup code, verify Chrome. */

// normalize environment
var RTCPeerConnection = null,
  getUserMedia = null,
  attachMediaStream = null,
  reattachMediaStream = null,
  browser = null,
  webRTCSupport = true;

if (navigator.webkitGetUserMedia) {
  browser = "chrome";

  // The RTCPeerConnection object.
  RTCPeerConnection = webkitRTCPeerConnection;
  /* TODO: Read and verify if any of this code is necessary */
  // // Get UserMedia (only difference is the prefix).
  // // Code from Adam Barth.
  // getUserMedia = navigator.webkitGetUserMedia.bind(navigator);

  // // Attach a media stream to an element.
  // attachMediaStream = function(element, stream) {
  //   element.autoplay = true;
  //   element.src = webkitURL.createObjectURL(stream);
  // };

  // reattachMediaStream = function(to, from) {
  //   to.src = from.src;
  // };

  // // The representation of tracks in a stream is changed in M26.
  // // Unify them for earlier Chrome versions in the coexisting period.
  // if (!webkitMediaStream.prototype.getVideoTracks) {
  //   webkitMediaStream.prototype.getVideoTracks = function() {
  //     return this.videoTracks;
  //   };
  //   webkitMediaStream.prototype.getAudioTracks = function() {
  //     return this.audioTracks;
  //   };
  // }

  // // New syntax of getXXXStreams method in M26.
  // if (!webkitRTCPeerConnection.prototype.getLocalStreams) {
  //   webkitRTCPeerConnection.prototype.getLocalStreams = function() {
  //     return this.localStreams;
  //   };
  //   webkitRTCPeerConnection.prototype.getRemoteStreams = function() {
  //     return this.remoteStreams;
  //   };
  // }
} else {
  webRTCSupport = false;
  console.error("Browser does not appear to be (Chrome) WebRTC-capable");
}
