App = {
  
  loading: false,
  contracts: {},

  load: async () => {
    await App.loadWeb3()
    await App.loadAccount()
    await App.loadContract()
    await App.render()
  
  },

  // https://medium.com/metamask/https-medium-com-metamask-breaking-change-injecting-web3-7722797916a8
  // intact column october parent trend slim spike cool around slender kiwi pyramid
  loadWeb3: async () => {
    if (typeof web3 !== 'undefined') {
      App.web3Provider = web3.currentProvider
      web3 = new Web3(web3.currentProvider)
    } else {
      App.web3Provider = new Web3.providers.HttpProvider('http://localhost:7545');
      web3 = new Web3(App.web3Provider);
    }
    // Modern dapp browsers...
    if (window.ethereum) {
      window.web3 = new Web3(ethereum)
      try {
        // Request account access if needed
        await ethereum.enable()
        // Acccounts now exposed
        web3.eth.sendTransaction({/* ... */})
      } catch (error) {
        // User denied account access...
      }
    }
    // Legacy dapp browsers...
    else if (window.web3) {
      App.web3Provider = web3.currentProvider
      window.web3 = new Web3(web3.currentProvider)
      // Acccounts always exposed
      web3.eth.sendTransaction({/* ... */})
    }
    // Non-dapp browsers...
    else {
      console.log('Non-Ethereum browser detected. You should consider trying MetaMask!')
    }
  },

 loadAccount: async() => {
  App.account = web3.eth.accounts[0];
 },

loadContract: async() => {
  const main = await $.getJSON('Main.json')
  App.contracts.Main = TruffleContract(main)
  App.contracts.Main.setProvider(App.web3Provider)
  App.main = await App.contracts.Main.deployed()
},

render: async () => {
      web3.eth.getCoinbase(function(err, account) {
      if (err === null) {
        App.account = account;
        $("#accountAddress").html(account);
      }
    });
  },

renderTasks: async () =>{

  const taskCount = await App.todoList.taskCount()
  const $taskTemplate = $('.taskTemplate')

  for (var i = 1;i<=taskCount;i++) {
    const task = await App.todoList.tasks(i)  //task return an array of Task contents
    const taskId = task[0].toNumber()
    const taskContent = task[1]
    const taskCompleted = task[2]

    //create HTML for the above task[]
    const $newTaskTemplate = $taskTemplate.clone()
    $newTaskTemplate.find('.content').html(taskContent)
    $newTaskTemplate.find('input')
            .prop('name', taskId)
            .prop('checked', taskCompleted)
            .on('click', App.toggleCompleted)

    //put the task in correct list
    if(taskCompleted){
      $('#completedTaskList').append($newTaskTemplate)
    }
    else{
      $('#taskList').append($newTaskTemplate)
    }

    $newTaskTemplate.show()
  }
},
  
  setStudent: async() => {
    App.setLoading(true)
    const usn = $('#usn').val()
    const name = $('#name').val()
    const cert = $('#certid').val()
    const br = $('#brch').val()
    await App.main.setStudent(usn,name,cert,br)
  },

  setTeacher: async() => {
   // App.setLoading(true)
    const name = $('#name1').val()
    const id = $('#deg').val()
    const deg = $('#des').val()
    const x = await App.main.setTeacher(name,id,deg)
    document.getElementById("status").innerHTML = x;
    console.log(x.val())
  },

  setLoading: (boolean) => {
    App.loading = boolean
    const loader = $('#loader')
    console.log(loader)
    const content = $('#content')
    console.log(content)
    if (boolean) {
      loader.show()
      content.hide()
    } else {
      loader.hide()
      content.show()
    }
  }
}

$(() => {
  $(window).load(() => {
    App.load()
  }) 
})


