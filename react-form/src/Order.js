import React, {useState} from 'react';
import './Order.css';
import OrderCreation from './OrderCreation';

import OrderSuccess from './OrderSuccess';

const Order = () => {
  const [isSubmitted, setIsSubmitted] = useState(false);
 function submitForm(){
   setIsSubmitted(true);
 }
  
  

 
  return (
  <>
      <div className='form-container'>
        <span className='close-btn'>×</span>
        <div className='form-content-left'>
          <img className='form-img' src='https://mail.google.com/mail/u/0?ui=2&ik=cc27f181e0&attid=0.1&permmsgid=msg-f:1704217228058428934&th=17a6988a22860606&view=fimg&sz=s0-l75-ft&attbid=ANGjdJ-_nuRHgtZYhvaAtD90pxVMWMD2El0lJhxCxOA0ej732X6arqe3cFpe4jw4zwpZM-34sk7cZmNnLzWoAZYc67gw2fVgs-T7qJTowxcsazmcnb4PNcni3PFhnRw&disp=emb&realattid=17a69886a2f510067321' alt='Order Submission' />
        </div>
        {!isSubmitted ? (
          <OrderCreation />
        ) : (
          <OrderSuccess />
        )}
        
     
          </div>
          </>
  );
};

export default Order;