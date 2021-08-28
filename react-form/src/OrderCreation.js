import React, {useState, useEffect} from 'react';
import useForm from './useForm';
import './Order.css';
import validate from './validate';
import getWeb3 from './getWeb3';
import SupplyChainProtocol from './contracts/SupplyChainProtocol.json'

const OrderCreation = ({submitForm}) => {
  const [web3, setWeb3] = useState(undefined);
  const [accounts, setAccounts] = useState(undefined);
  const [contract, setContract] = useState(undefined);
  const [name, setName] = useState(undefined);
  const [order, setOrder] = useState(undefined);
  const [supplyChainProtocol, setSupplyChainProtocol] = useState({});
  const {handleChange, handleSubmit, values} = useForm (
        submitForm,
        validate
        
    );

    useEffect(() => {
      const init = async () => {
        const web3 = await getWeb3();
        const accounts = await web3.eth.getAccounts(); 
        const networkId = await web3.eth.net.getId();
        const deployedNetwork = SupplyChainProtocol.networks[networkId];
        const contract = new web3.eth.Contract(
          SupplyChainProtocol.abi,
          deployedNetwork && deployedNetwork.address,
          {from: accounts[0], nonce: "4"}
        );
        setSupplyChainProtocol(supplyChainProtocol);
        setName(name);
        setWeb3(web3);
        setAccounts(accounts);
        setContract(contract);
        setOrder(order);
    
      }
      init();
      window.ethereum.on("accountsChanged", (accounts) => {
        setAccounts(accounts);
      });
    }, [])
    const isReady = () => {
      return (
        typeof contract !== "undefined" &&
        typeof web3 !== "undefined" &&
        typeof accounts !== "undefined"
      );
    };
    
    useEffect(() => {
      if(isReady) {
        const abi = SupplyChainProtocol.abi
        console.log(abi);
      }
      
    }, [accounts, contract, web3])
    
    async function updateOrders() {
      const id = parseInt(await contract.methods.getOrderId().call());
      const order = await contract.methods.getOrder(id).call();
      setOrder({
        id: order[0],
        cost: order[1],
        productName: order[2],
        description: order[3],
        leadTime_in_days: order[4]
      })
    }
    async function createOrder(e) {
      e.preventDefault();
      const id = e.target.elements[0].value;
      const cost = e.target.elements[1].value;
      const productName = e.target.elements[2].value;
      const description = e.target.elements[3].value;
      const leadTime = parseInt(e.target.elements[4].value);
      const owner = await contract.methods.ownerOf(id).call();
      await contract.methods._createOrder(id, cost, productName, description, leadTime, owner).send({from: accounts[0]})
      await updateOrders();
    }
    async function getBalance(w3, c, account) {
      try {
        let balance = await c.methods.balanceOf(account).call();
        balance = parseFloat(w3.utils.fromWei(balance, "ether"));
        return Promise.resolve(balance);
      } catch(e) {
        return Promise.reject(e);
      }
    }
    return (
        <div className='form-content-right'>
        <form onSubmit={e => createOrder(e)} className='form' noValidate>
           <h1>
           Submit Order
           </h1>
           <div className='form-inputs'>
             <label className='form-label'>ID</label>
             <input
               className='form-input'
               type='ID'
               name='ID'
               value={values.ID}
               onChange={handleChange}
               
             />
           </div>
           <div className='form-inputs'>
             <label className='form-label'>Cost</label>
             <input
               className='form-input'
               type='text'
               name='Cost'
               value={values.Cost}
               onChange={handleChange}
             />
           </div>
           <div className='form-inputs'>
             <label className='form-label'>Product Name</label>
             <input
               className='form-input'
               type='Product Name'
               name='productName'
               value={values.productName}
               onChange={handleChange}
   
             />
           </div>
           <div className='form-inputs'>
             <label className='form-label'>Description</label>
             <input
               className='form-input'
               type='text'
               name='Description'
               value={values.Description}
               onChange={handleChange}
   
             />
           </div>
           <div className='form-inputs'>
             <label className='form-label'>Lead Time</label>
             <input
               className='form-input'
               type='integer'
               name='leadTime'
               value={values.leadTime}
               onChange={handleChange}
   
             />
           </div>
           <button className='form-input-btn' type='submit'>
             Create Product Order
           </button>
         </form>
         
       </div>
   
    );
};
export default OrderCreation;