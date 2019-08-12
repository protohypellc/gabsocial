'use strict';

import React from 'react';
import { connect } from 'react-redux';
import PropTypes from 'prop-types';
import ImmutablePropTypes from 'react-immutable-proptypes';
import classNames from 'classnames';
import { FormattedMessage, injectIntl, defineMessages } from 'react-intl';
import { Link } from 'react-router-dom';
import Icon from 'gabsocial/components/icon';
import { me } from 'gabsocial/initial_state';
import { fetchLists } from 'gabsocial/actions/lists';
import { createSelector } from 'reselect';

const messages = defineMessages({
  show: { id: 'column_header.show_settings', defaultMessage: 'Show settings' },
  hide: { id: 'column_header.hide_settings', defaultMessage: 'Hide settings' },
  homeTitle: { id: 'home_column_header.home', defaultMessage: 'Home' },
  allTitle: { id: 'home_column_header.all', defaultMessage: 'All' },
  listTitle: { id: 'home_column.lists', defaultMessage: 'Lists' },
});

const getOrderedLists = createSelector([state => state.get('lists')], lists => {
  if (!lists) {
    return lists;
  }

  return lists.toList().filter(item => !!item).sort((a, b) => a.get('title').localeCompare(b.get('title')));
});

const mapStateToProps = state => {
  return {
    lists: getOrderedLists(state),
  };
};

class ColumnHeader extends React.PureComponent {

  static contextTypes = {
    router: PropTypes.object,
  };

  static propTypes = {
    intl: PropTypes.object.isRequired,
    dispatch: PropTypes.func.isRequired,
    active: PropTypes.bool,
    children: PropTypes.node,
    activeItem: PropTypes.string,
    activeSubItem: PropTypes.string,
    lists: ImmutablePropTypes.list,
  };

  state = {
    collapsed: true,
    animating: false,
    expandedFor: null, //lists, groups, etc.
  };

  componentDidMount() {
    this.props.dispatch(fetchLists());
  }

  handleToggleClick = (e) => {
    e.stopPropagation();
    this.setState({ collapsed: !this.state.collapsed, animating: true });
  }

  handleTransitionEnd = () => {
    this.setState({ animating: false });
  }

  expandLists = () => {
    this.setState({
      expandedFor: 'lists',
    });
  }

  render () {
    const { active, children, intl: { formatMessage }, activeItem, activeSubItem, lists } = this.props;
    const { collapsed, animating, expandedFor } = this.state;

    const wrapperClassName = classNames('column-header__wrapper', {
      'active': active,
    });

    const buttonClassName = classNames('column-header', {
      'active': active,
    });

    const collapsibleClassName = classNames('column-header__collapsible', {
      'collapsed': collapsed,
      'animating': animating,
    });

    const collapsibleButtonClassName = classNames('column-header__button', {
      'active': !collapsed,
    });

    const expansionClassName = classNames('column-header column-header__expansion', {
      'open': expandedFor,
    });

    let extraContent, collapseButton;

    if (children) {
      extraContent = (
        <div key='extra-content' className='column-header__collapsible__extra'>
          {children}
        </div>
      );

      collapseButton = <button className={collapsibleButtonClassName} title={formatMessage(collapsed ? messages.show : messages.hide)} aria-label={formatMessage(collapsed ? messages.show : messages.hide)} aria-pressed={collapsed ? 'false' : 'true'} onClick={this.handleToggleClick}><Icon id='sliders' /></button>;
    }

    const collapsedContent = [
      extraContent,
    ];

    let expandedContent = null;
    if ((expandedFor === 'lists' || activeItem === 'lists') && lists) {
      expandedContent = lists.map(list =>
        <Link
          key={list.get('id')}
          to={`/list/${list.get('id')}`}
          className={
            classNames('btn btn--sub grouped', {
              'active': list.get('id') === activeSubItem
            })
          }
        >
          {list.get('title')}
        </Link>
      )
    }

    return (
      <div className={wrapperClassName}>
        <h1 className={buttonClassName}>
          <Link to='/home' className={classNames('btn grouped', {'active': 'home' === activeItem})}>
            <Icon id='home' fixedWidth className='column-header__icon' />
            {formatMessage(messages.homeTitle)}
          </Link>

          <Link to='/timeline/all' className={classNames('btn grouped', {'active': 'all' === activeItem})}>
            <Icon id='globe' fixedWidth className='column-header__icon' />
            {formatMessage(messages.allTitle)}
          </Link>

          { lists.size > 0 &&
            <a onClick={this.expandLists} className={classNames('btn grouped', {'active': 'lists' === activeItem})}>
              <Icon id='list' fixedWidth className='column-header__icon' />
              {formatMessage(messages.listTitle)}
            </a>
          }
          { lists.size == 0 &&
            <Link to='/lists' className='btn grouped'>
              <Icon id='list' fixedWidth className='column-header__icon' />
              {formatMessage(messages.listTitle)}
            </Link>
          }

          <div className='column-header__buttons'>
            {collapseButton}
          </div>
        </h1>

        {
          expandedContent &&
          <h1 className={expansionClassName}>
            {expandedContent}
          </h1>
        }

        <div className={collapsibleClassName} tabIndex={collapsed ? -1 : null} onTransitionEnd={this.handleTransitionEnd}>
          <div className='column-header__collapsible-inner'>
            {(!collapsed || animating) && collapsedContent}
          </div>
        </div>
      </div>
    );
  }
}

export default injectIntl(connect(mapStateToProps)(ColumnHeader));
