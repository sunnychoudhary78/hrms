class Userdetails {
  String? id;
  String? userId;
  String? associatesName;
  String? payrollCode;
  String? designation;
  String? departmentName;
  String? managerId;
  String? departmentHeadId;
  String? doj;
  String? totalExperience;
  String? workLocation;
  String? contactPrimary;
  String? email;
  String? bloodGroup;

  // 🏢 COMPANY
  String? companyId; // ← THIS IS THE KEY FIX
  String? companyName;

  // 🖼️ PROFILE
  String? profilePicture;

  // 👥 RELATIONS
  Manager? manager;
  Manager? departmentHead;

  Userdetails({
    this.id,
    this.userId,
    this.associatesName,
    this.payrollCode,
    this.designation,
    this.departmentName,
    this.managerId,
    this.departmentHeadId,
    this.doj,
    this.totalExperience,
    this.workLocation,
    this.contactPrimary,
    this.email,
    this.bloodGroup,
    this.companyId,
    this.companyName,
    this.profilePicture,
    this.manager,
    this.departmentHead,
  });

  Userdetails.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    associatesName = json['associates_name'];
    payrollCode = json['payroll_code'];
    designation = json['designation'];

    // 🔥 FIXED LINE
    departmentName = json['department']?['name'];

    managerId = json['manager_id'];
    departmentHeadId = json['department_head_id'];
    doj = json['doj'];
    totalExperience = json['total_experience'];
    workLocation = json['work_location'];
    contactPrimary = json['contact_primary'];
    email = json['email'];
    bloodGroup = json['blood_group'];

    companyId = json['company_id'];
    companyName = json['company']?['name'];

    profilePicture = json['profile_picture'];

    manager = json['manager'] != null
        ? Manager.fromJson(json['manager'])
        : null;

    departmentHead = json['department_head'] != null
        ? Manager.fromJson(json['department_head'])
        : null;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'associates_name': associatesName,
      'payroll_code': payrollCode,
      'designation': designation,
      'department_name': departmentName,
      'manager_id': managerId,
      'department_head_id': departmentHeadId,
      'doj': doj,
      'total_experience': totalExperience,
      'work_location': workLocation,
      'contact_primary': contactPrimary,
      'email': email,
      'blood_group': bloodGroup,
      'company_id': companyId,
      'profile_picture': profilePicture,
      'manager': manager?.toJson(),
      'department_head': departmentHead?.toJson(),
    };
  }
}

// ───────────────── MANAGER MODEL ─────────────────

class Manager {
  String? id;
  String? name;
  String? email;

  Manager({this.id, this.name, this.email});

  Manager.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    email = json['email'];
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'email': email};
  }
}
