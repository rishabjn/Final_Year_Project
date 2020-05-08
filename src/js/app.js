App = {
  
  loading: false,
  contracts: {},

  load: async () => {
    await App.loadWeb3()
    await App.loadAccount()
    await App.loadContract()
    await App.render()
    await App.listenForEvents()
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
  // await App.listenForEvents()
},
  // Listen for events emitted from the contract
listenForEvents: function() {
    App.contracts.Main.deployed().then(function(instance) {
      // https://github.com/MetaMask/metamask-extension/issues/2393
      instance.Check({}, {
        toBlock: 'latest'
      }).watch(function(error, event) {
        console.log("event triggered", event)
        var res = event['args']['certId']
        $('#logs').append(res)
      });
    });
  },
render: async () => {
      //updating the account which is currently in work...
      web3.eth.getCoinbase(function(err, account) {
      if (err === null) {
        App.account = account;
        $("#accountAddress").html(account);
      }
    });
      
      //Printing all the student certificate in the network..
      var studentData = $("#studentData")
      const stud = await App.main.getStudentAddress()
      for (var i = 0; i < stud.length; i++) {
        const studData = await App.main.getStudent(stud[i]);
        var candidateTemplate = "<tr><th>" + stud[i] + "</th><td>" + studData[2] + "</td><td>" + studData[5]+ "</td><td>" +studData[0] +"</td><td>"  + studData[1] +"</td><td>"+ studData[3] +"</td><td>" +studData[4]  +"</td></tr>"
        studentData.append(candidateTemplate);
       }
      //Printing all the teachers in the network...
      var teacherData = $("#teacherData")
      const teach = await App.main.getTeacherAddress()
      for (var i = 0; i < teach.length; i++) {
        const teachData = await App.main.getTeacher(teach[i]);
        var candidateTemplate = "<tr><th>" + teachData[0] + "</th><td>" + teachData[1] + "</td><td>" +teachData[2] +"</td><td>" +teachData[3] + "</td></tr>"
        teacherData.append(candidateTemplate);
       }
       //Printing all the verified cert in the network...
       var studentData = $("#verifyData")
      const veri = await App.main.getStudentAddress()
      for (var i = 0; i < stud.length; i++) {
        const studData = await App.main.getStudent(stud[i]);
        if(studData[5]>0){
        var candidateTemplate = "<tr><th>" +  studData[1]  +"</td><td>"+ studData[0]+"</td><td>"+ studData[3] +"</td><td>" +studData[4]  +"</td></tr>"
        studentData.append(candidateTemplate);
        }
      }
  },
  
  setStudent: async() => {
    App.setLoading(true)
    const usn = $('#usn').val()
    const name = $('#name').val()
    const cert = $('#certid').val()
    const certInfo = $('#certinfo').val()
    const br = $('#brch').val()
    await App.main.setStudent(usn,name,cert,certInfo,br)
    await App.render()

    location.reload()
    
  },

  setTeacher: async() => {
    App.setLoading(true)
    const name = $('#name1').val()
    const id = $('#deg').val()
    const deg = $('#des').val()
    const domain = $('#domain').val()
    await App.main.setTeacher(name,id,deg,domain)
    await App.render()
    window.location.reload()
  },

  verify: async() => {
    // App.setLoading(true)

    const addr = $('#addr').val()
    const hash = $('#hash').val() 
    const res = await App.main.verify(addr,hash)
    await App.render()
    window.location.reload()
  },

  setLoading: (boolean) => {
    App.loading = boolean
    const loader = $('#loader')
    console.log(loader)
    const content = $('#content')
    console.log(content)
  }
}

$(() => {
  $(window).load(() => {
    App.load()
  }) 
})


