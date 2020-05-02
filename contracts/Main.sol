pragma solidity ^0.5.0;

contract Main {
    
    struct Student{
        uint usn;
        string name;
        string certId;
        string college;
        address[3] verifier;
        uint count; 
    }
    mapping(address => Student) students;
    event Check(address indexed _from,address indexed _to, string certId, uint count, address[3] verify);
    address[] public studentacc;
    string[] public cerificateHash;
    
   struct Teacher{
       string name;
       uint id;
       string post;
   }
   mapping (address => Teacher) teachers;
   address[] public teacheracc;
   
    function setStudent(uint u, string memory n, string memory cer, string memory coll)  public returns (bool) {
        uint tFlag=0;
        for(uint i=0;i<teacheracc.length;i++){
            if(msg.sender == teacheracc[i]){
                tFlag=1;
                break;
            }
            else{
                tFlag=0;
            }
        }
        if(tFlag==1){
            return false;
        }
        
        uint sFlag=0;
        for(uint i=0;i<studentacc.length;i++){
            if(msg.sender == studentacc[i]){
                sFlag=1;
                break;
            }
            else{
                sFlag=0;
            }
        }
        if(sFlag==1){
            return false;
        }
        
        Student storage student = students[msg.sender];
        student.usn = u;
        student.name = n;
        student.certId = cer;
        student.college = coll;
        student.count = 0;
        studentacc.push(msg.sender);
        cerificateHash.push(cer);
        return true;
    }
    function getStudent(address ins) view public returns (uint, string memory, string memory, string memory){
        return (students[ins].usn, students[ins].name, students[ins].certId, students[ins].college);
    }
    function getStudentAddress() view public returns (address[] memory)  {
        return studentacc;
    }

   function setTeacher(string memory n, uint i,string memory d) public returns (bool) {
       
        uint tFlag=0;
        for(i=0;i<teacheracc.length;i++){
            if(msg.sender == teacheracc[i]){
                tFlag=1;
                break;
            }
            else{
                tFlag=0;
            }
        }
        if(tFlag==1){
            return false;
        }
        
        uint sFlag=0;
        for(i=0;i<studentacc.length;i++){
            if(msg.sender == studentacc[i]){
                sFlag=1;
                break;
            }
            else{
                sFlag=0;
            }
        }
        if(sFlag==1){
            return false;
        }
        
        Teacher storage teacher = teachers[msg.sender];
        teacher.name = n;
        teacher.id = i;
        teacher.post = d;
        teacheracc.push(msg.sender);
        return true;
   }
   function getTeacherAddress() view public returns (address[] memory)  {
        return teacheracc;
    }

    function getTeacher(address ins) view public returns (string memory, uint, string memory) {
        return (teachers[ins].name, teachers[ins].id, teachers[ins].post);
    }
    
    function verify(address studAdd) payable public returns(string memory){
        //if teacher is a valid person in the network
        uint tFlag=0;
        for(uint i=0;i<teacheracc.length;i++){
            if(msg.sender == teacheracc[i]){
                tFlag=1;
                break;
            }
            else{
                tFlag=0;
            }
        }
        if(tFlag==0){
            emit Check(msg.sender, studAdd, "Teacher Not in Network: Invalid Address",students[studAdd].count, students[studAdd].verifier);
            return "Invalid address";
        }
        //if the student address is valid in the network
        uint sFlag=0;
        for(uint i=0;i<studentacc.length;i++){
            if(studAdd == studentacc[i]){
                sFlag=1;
                break;
            }
            else{
                sFlag=0;
            }
        }
        if(sFlag==0){
            emit Check(msg.sender, studAdd, "Certificate Not in Network: Invalid Address",students[studAdd].count, students[studAdd].verifier);
            return "Invalid address";
        }
        //if the certificate to be verified is added to the network by any student or not
        //Checking if the cerificate is verified by 3 teachers before
        if(students[studAdd].count==3){
            emit Check(msg.sender, studAdd, "Verified Certificate",students[studAdd].count, students[studAdd].verifier);
            return "Verififed Certificate";
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