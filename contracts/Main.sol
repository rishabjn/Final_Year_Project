pragma solidity ^0.5.0;

contract Main {

    struct Student{
        string usn;
        string name;
        string certId;
        string certInfo;
        string branch;
        address[3] verifier;
        uint count;
    }
    mapping(address => Student) students;
    mapping(address => bool) studCheck;
    event Check(address indexed _from,address indexed _to, string certId, uint count, address[3] verify);
    address[] public studentacc;
    //string[] public cerificateHash;
    mapping(string => bool) cerificateHash;
    
   struct Teacher{
       string name;
       string id;
       string post;
       string domain;
   }
   mapping (address => Teacher) teachers;
   mapping(address => bool) teachCheck;
   address[] public teacheracc;
   
    function setStudent(string memory u, string memory n, string memory cer,string memory ceri, string memory coll)  public returns (bool) {
        if(studCheck[msg.sender] == true) return false;
        
        if(teachCheck[msg.sender] == true) return false;
        
        Student storage student = students[msg.sender];
        student.usn = u;
        student.name = n;
        student.certId = cer;
        student.certInfo = ceri;
        student.branch = coll;
        student.count = 0;
        studentacc.push(msg.sender);
        studCheck[msg.sender] = true;
        cerificateHash[cer] = true;
        return true;
    }
    function getStudent(address ins) view public returns (string memory, string memory, string memory, string memory, string memory, uint){
        return (students[ins].usn, students[ins].name, students[ins].certId,students[ins].certInfo, students[ins].branch,students[ins].count);
    }
    function getVerifyedBy(address ins) view public returns (uint, address,address,address){
       return (students[ins].count, students[ins].verifier[0],students[ins].verifier[1],students[ins].verifier[2]);
    }
    function getStudentAddress() view public returns (address[] memory)  {
        return studentacc;
    }

   function setTeacher(string memory n, string memory i,string memory d, string memory dom ) public returns (bool) {
       
        if(teachCheck[msg.sender]==true) return false;
        
        if(studCheck[msg.sender] == true) return false;
        Teacher storage teacher = teachers[msg.sender];
        teacher.name = n;
        teacher.id = i;
        teacher.post = d;
        teacher.domain = dom;
        teacheracc.push(msg.sender);
        teachCheck[msg.sender] = true;
        return true;
   }
   function getTeacherAddress() view public returns (address[] memory)  {
        return teacheracc;
    }

    function getTeacher(address ins) view public returns (string memory, string memory, string memory, string memory) {
        return (teachers[ins].name, teachers[ins].id, teachers[ins].post, teachers[ins].domain);
    }
    function destroy (address addr) public {
        //require(exists(msg.sender));
        delete students[addr];
        //emit UserDestroyed(msg.sender);
  }
    function verify(address studAdd, string memory certHash) payable public returns(string memory){
        

        //if teacher is a valid person in the network
        if(teachCheck[msg.sender]==false){
            emit Check(msg.sender, studAdd, "Teacher Not in Network: Invalid Address",students[studAdd].count, students[studAdd].verifier);
            return "Invalid address";
        }
        //if the Certificate address is valid in the network
        if(studCheck[studAdd] == false){
            emit Check(msg.sender, studAdd, "Certificate Not in Network: Invalid Address",students[studAdd].count, students[studAdd].verifier);
            return "Invalid address";
        }
        //if the certificate to be verified is added to the network by any student or not
        //Checking if the cerificate is verified by 3 teachers before
        if(students[studAdd].count==3){
            emit Check(msg.sender, studAdd, "Verified Certificate",students[studAdd].count, students[studAdd].verifier);
            return "Verififed Certificate";
        }
                //Certificate Hash check 
       if(cerificateHash[certHash]==false){
            emit Check(msg.sender, studAdd, "Invalid Certificate Hash",students[studAdd].count, students[studAdd].verifier);
            return "Invalid Certificate Hash";
        }
        
        //For loop is to check if the certificate is verified by teacher before...
        for (uint i=0; i<3; i++){
            if(msg.sender == students[studAdd].verifier[i]){
                emit Check(msg.sender,studAdd, "Certificated Can be verified only Once...",students[studAdd].count, students[studAdd].verifier);
                return "Certificated can be verified only Once";
            }
        }
        // If the certificate is not verified by the teacher then it verifies and the teacher address gets added to the student verifier array
          
          students[studAdd].verifier[students[studAdd].count++] = msg.sender;
          emit Check(msg.sender, studAdd, "Verifier Address added to array[]" ,students[studAdd].count, students[studAdd].verifier);
         return "Verifier Address added to array[]";
    }
}