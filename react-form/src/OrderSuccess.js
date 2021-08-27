import React from 'react';
import './Order.css';
import OrderCreation from './OrderCreation';
const orderSuccess = () => {
  return (
    <div className='form-content-right' >
      <h1 className='form-success'>Order Created</h1>
    </div>
  );
};

export default orderSuccess;