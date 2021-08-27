import React from 'react';
import './App.css';
import useForm from './useForm';
import validate from './validate';
import Order from './Order.js';

function App () {
  const {handleChange, values } = useForm(
    validate
  );

  
 
  

 
 
 
 

  return (
    <div>
    <Order/>
</div>
);
  
  }
  

export default App;