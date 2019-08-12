import React from 'react';
import { connect } from 'react-redux';
import ImmutablePropTypes from 'react-immutable-proptypes';
import PropTypes from 'prop-types';
import ImmutablePureComponent from 'react-immutable-pure-component';
import { FormattedMessage } from 'react-intl';
import { NavLink } from 'react-router-dom';

const mapStateToProps = state => ({
  value: state.getIn(['search', 'value']),
  submitted: state.getIn(['search', 'submitted']),
});

class Header extends ImmutablePureComponent {

  static propTypes = {
    value: PropTypes.string,
    submitted: PropTypes.bool,
  };

  state = {
    submittedValue: '',
  };

  componentWillReceiveProps (nextProps) {
    if (nextProps.submitted) {
      const submittedValue = nextProps.value;
      this.setState({submittedValue})
    }
  }

  render () {
    const { submittedValue } = this.state;

    if (!submittedValue) {
      return null;
    }

    return (
      <div className='search-header'>
        <div className='search-header__text-container'>
          <h1 className='search-header__title-text'>
            {submittedValue}
          </h1>
        </div>
        <div className='search-header__type-filters'>
          <div className='account__section-headline'>
            <div className='search-header__type-filters-tabs'>
              <NavLink to='/search' activeClassName='active'>
                <FormattedMessage id='search_results.top' defaultMessage='Top' />
              </NavLink>
              {/*<NavLink to='/search/gabs' activeClassName='active'>
                <FormattedMessage id='search_results.statuses' defaultMessage='Gabs' />
              </NavLink>
              <NavLink to='/search/people' activeClassName='active'>
                <FormattedMessage id='search_results.accounts' defaultMessage='People' />
              </NavLink>
              <NavLink to='/search/hashtags' activeClassName='active'>
                <FormattedMessage id='search_results.hashtags' defaultMessage='Hashtags' />
              </NavLink>
              <NavLink to='/search/groups' activeClassName='active'>
                <FormattedMessage id='search_results.groups' defaultMessage='Groups' />
              </NavLink>*/}
            </div>
          </div>
        </div>
      </div>
    );
  }
}

export default connect(mapStateToProps)(Header);
