import { connect } from 'react-redux';
import Poll from 'gabsocial/components/poll';

const mapStateToProps = (state, { pollId }) => ({
  poll: state.getIn(['polls', pollId]),
});

export default connect(mapStateToProps)(Poll);
