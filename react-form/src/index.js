import React from 'react';
import ReactDOM from 'react-dom';
import App from './App';

window.addEventListener('load', async function () {
  try {
    return await window.ethereum.request({
      method: 'eth_requestAccounts'
    }) 
  } catch (e) {
    console.log(e)
  }
})

ReactDOM.render(
  
        <App />
        
  ,
document.getElementById('root')
);