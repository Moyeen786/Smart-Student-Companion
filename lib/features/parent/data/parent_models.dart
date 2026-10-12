import 'package:flutter/material.dart';
import 'package:smart_student_companion/core/theme/app_colors.dart';
import 'package:smart_student_companion/models/user_model.dart';

class SubjectAttendance {
  const SubjectAttendance({
    required this.subjectCode,
    required this.subjectName,
    required this.attended,
    required this.total,
    required this.percentage,
    required this.teacherName,
    this.isWarning = false,
  });

  final String subjectCode;
  final String subjectName;
  final int attended;
  final int total;
  final double percentage;
  final String teacherName;
  final bool isWarning;
}

class SubjectPerformance {
  const SubjectPerformance({
    required this.subjectCode,
    required this.subjectName,
    required this.internalScore,
    required this.maxInternal,
    required this.grade,
    required this.credits,
    required this.trend,
  });

  final String subjectCode;
  final String subjectName;
  final int internalScore;
  final int maxInternal;
  final String grade;
  final int credits;
  final String trend; // e.g. "+5%", "Steady", "-2%"
}

class AcademicExam {
  const AcademicExam({
    required this.title,
    required this.subject,
    required this.dateString,
    required this.time,
    required this.venue,
    this.daysLeft = 0,
  });

  final String title;
  final String subject;
  final String dateString;
  final String time;
  final String venue;
  final int daysLeft;
}

class AcademicAssignment {
  const AcademicAssignment({
    required this.title,
    required this.subject,
    required this.dueDateString,
    required this.status, // "Pending", "Submitted", "Graded"
    this.score,
    this.maxScore,
    this.isUrgent = false,
  });

  final String title;
  final String subject;
  final String dueDateString;
  final String status;
  final int? score;
  final int? maxScore;
  final bool isUrgent;
}

enum InsightType { warning, reminder, improvement, deadline }

class SmartInsight {
  const SmartInsight({
    required this.type,
    required this.title,
    required this.message,
    required this.icon,
    required this.accentColor,
    required this.badgeText,
  });

  final InsightType type;
  final String title;
  final String message;
  final IconData icon;
  final Color accentColor;
  final String badgeText;
}

class ParentAnnouncement {
  const ParentAnnouncement({
    required this.title,
    required this.category,
    required this.date,
    required this.summary,
    this.isUrgent = false,
  });

  final String title;
  final String category;
  final String date;
  final String summary;
  final bool isUrgent;
}

class AcademicActivity {
  const AcademicActivity({
    required this.title,
    required this.timeAgo,
    required this.description,
    required this.icon,
    required this.color,
  });

  final String title;
  final String timeAgo;
  final String description;
  final IconData icon;
  final Color color;
}

class ChildAcademicSummary {
  const ChildAcademicSummary({
    required this.student,
    required this.cgpa,
    required this.overallAttendance,
    required this.totalClasses,
    required this.attendedClasses,
    required this.attendanceStatus,
    required this.subjectAttendances,
    required this.subjectPerformances,
    required this.upcomingExams,
    required this.upcomingAssignments,
    required this.smartInsights,
    required this.announcements,
    required this.recentActivities,
  });

  final UserModel student;
  final double cgpa;
  final double overallAttendance;
  final int totalClasses;
  final int attendedClasses;
  final String attendanceStatus;
  final List<SubjectAttendance> subjectAttendances;
  final List<SubjectPerformance> subjectPerformances;
  final List<AcademicExam> upcomingExams;
  final List<AcademicAssignment> upcomingAssignments;
  final List<SmartInsight> smartInsights;
  final List<ParentAnnouncement> announcements;
  final List<AcademicActivity> recentActivities;

  factory ChildAcademicSummary.generateForStudent(UserModel student) {
    final effectiveCgpa = student.cgpa > 0 ? student.cgpa : 8.42;
    final effectiveAttendance =
        student.overallAttendance > 0 ? student.overallAttendance : 89.4;

    final subjectAttendances = [
      const SubjectAttendance(
        subjectCode: 'CS501',
        subjectName: 'Computer Networks',
        attended: 42,
        total: 45,
        percentage: 93.3,
        teacherName: 'Dr. S. Mehta',
      ),
      const SubjectAttendance(
        subjectCode: 'CS502',
        subjectName: 'Operating Systems',
        attended: 38,
        total: 42,
        percentage: 90.5,
        teacherName: 'Prof. Anita Rao',
      ),
      const SubjectAttendance(
        subjectCode: 'CS503',
        subjectName: 'Design & Analysis of Algorithms',
        attended: 37,
        total: 41,
        percentage: 90.2,
        teacherName: 'Dr. K. Verma',
      ),
      const SubjectAttendance(
        subjectCode: 'CS504',
        subjectName: 'Database Management Systems',
        attended: 39,
        total: 41,
        percentage: 95.1,
        teacherName: 'Prof. R. Menon',
      ),
      const SubjectAttendance(
        subjectCode: 'CS505',
        subjectName: 'Data Structures & OOP Lab',
        attended: 23,
        total: 34,
        percentage: 67.6,
        teacherName: 'Dr. P. Nair',
        isWarning: true,
      ),
    ];

    final subjectPerformances = [
      const SubjectPerformance(
        subjectCode: 'CS501',
        subjectName: 'Computer Networks',
        internalScore: 46,
        maxInternal: 50,
        grade: 'A+',
        credits: 4,
        trend: '+4%',
      ),
      const SubjectPerformance(
        subjectCode: 'CS502',
        subjectName: 'Operating Systems',
        internalScore: 44,
        maxInternal: 50,
        grade: 'A',
        credits: 4,
        trend: '+12%',
      ),
      const SubjectPerformance(
        subjectCode: 'CS503',
        subjectName: 'Design & Analysis of Algorithms',
        internalScore: 43,
        maxInternal: 50,
        grade: 'A',
        credits: 4,
        trend: '+2%',
      ),
      const SubjectPerformance(
        subjectCode: 'CS504',
        subjectName: 'Database Management Systems',
        internalScore: 48,
        maxInternal: 50,
        grade: 'O',
        credits: 3,
        trend: '+5%',
      ),
      const SubjectPerformance(
        subjectCode: 'CS505',
        subjectName: 'Data Structures & OOP Lab',
        internalScore: 32,
        maxInternal: 50,
        grade: 'B+',
        credits: 2,
        trend: '-6%',
      ),
    ];

    final upcomingExams = [
      const AcademicExam(
        title: 'Mid-Term Theory Examination',
        subject: 'Computer Networks (CS501)',
        dateString: 'Oct 14, 2026',
        time: '10:00 AM - 12:00 PM',
        venue: 'Hall AB-204',
        daysLeft: 5,
      ),
      const AcademicExam(
        title: 'Mid-Term Theory Examination',
        subject: 'Operating Systems (CS502)',
        dateString: 'Oct 16, 2026',
        time: '10:00 AM - 12:00 PM',
        venue: 'Hall CC-301',
        daysLeft: 7,
      ),
      const AcademicExam(
        title: 'Mid-Term Theory Examination',
        subject: 'Design & Analysis of Algorithms',
        dateString: 'Oct 19, 2026',
        time: '02:00 PM - 04:00 PM',
        venue: 'Hall AB-105',
        daysLeft: 10,
      ),
    ];

    final upcomingAssignments = [
      const AcademicAssignment(
        title: 'Process Scheduling Simulation Report',
        subject: 'Operating Systems',
        dueDateString: 'Due in 24 hours',
        status: 'In Progress',
        isUrgent: true,
      ),
      const AcademicAssignment(
        title: 'Network Routing Case Study',
        subject: 'Computer Networks',
        dueDateString: 'Oct 18, 2026',
        status: 'Pending',
      ),
      const AcademicAssignment(
        title: 'B-Tree & Indexing Practical Module',
        subject: 'Database Systems',
        dueDateString: 'Oct 22, 2026',
        status: 'Submitted',
        score: 19,
        maxScore: 20,
      ),
    ];

    final smartInsights = [
      const SmartInsight(
        type: InsightType.warning,
        title: 'Attendance Alert',
        message:
            'Attendance in Data Structures & OOP Lab is at 67.6%, below the 75% threshold. 3 classes needed to avoid condonation.',
        icon: Icons.warning_amber_rounded,
        accentColor: AppColors.danger,
        badgeText: 'Action Required',
      ),
      const SmartInsight(
        type: InsightType.reminder,
        title: 'Upcoming Examination',
        message:
            'Mid-Term Exam for Computer Networks starts in 5 days (Oct 14). Hall ticket verification complete.',
        icon: Icons.event_note_rounded,
        accentColor: AppColors.primary,
        badgeText: '5 Days Left',
      ),
      const SmartInsight(
        type: InsightType.improvement,
        title: 'Academic Improvement',
        message:
            'Scored 88% in Operating Systems Internal Test 2 (+12% improvement from Test 1).',
        icon: Icons.trending_up_rounded,
        accentColor: AppColors.success,
        badgeText: '+12% Gain',
      ),
      const SmartInsight(
        type: InsightType.deadline,
        title: 'Urgent Assignment Deadline',
        message:
            'Process Scheduling Simulation report is due within 24 hours. Current status: In Progress.',
        icon: Icons.timer_outlined,
        accentColor: AppColors.warning,
        badgeText: 'Due Soon',
      ),
    ];

    final announcements = [
      const ParentAnnouncement(
        title: 'Parent-Teacher Consultative Meeting (PTM)',
        category: 'Institutional',
        date: 'Oct 25, 2026',
        summary:
            'Semester 5 virtual parent-faculty interaction session scheduled. Time slots will be shared via email.',
        isUrgent: true,
      ),
      const ParentAnnouncement(
        title: 'End-Semester Exam Schedule Draft Released',
        category: 'Examination Cell',
        date: 'Oct 02, 2026',
        summary:
            'Students are advised to review the tentative timetable and submit clashes by Oct 12.',
      ),
      const ParentAnnouncement(
        title: 'Campus Internship Drive - Phase 1',
        category: 'Placement Cell',
        date: 'Sep 29, 2026',
        summary:
            'Pre-placement talks starting next week for CSE, IT and ECE departments.',
      ),
    ];

    final recentActivities = [
      const AcademicActivity(
        title: 'Assignment Submitted',
        timeAgo: 'Yesterday, 4:30 PM',
        description: 'B-Tree & Indexing Practical submitted for DBMS',
        icon: Icons.task_alt_rounded,
        color: AppColors.success,
      ),
      const AcademicActivity(
        title: 'Internal Marks Posted',
        timeAgo: '2 days ago',
        description: 'Scored 46/50 in Computer Networks Mid-Term',
        icon: Icons.grade_rounded,
        color: AppColors.primary,
      ),
      const AcademicActivity(
        title: 'Lab Attendance Recorded',
        timeAgo: '3 days ago',
        description: 'Marked Present in DBMS Practical Lab 04',
        icon: Icons.how_to_reg_rounded,
        color: AppColors.accent,
      ),
      const AcademicActivity(
        title: 'Attendance Warning Triggered',
        timeAgo: '5 days ago',
        description: 'Data Structures Lab attendance dipped below 70%',
        icon: Icons.notification_important_rounded,
        color: AppColors.danger,
      ),
    ];

    return ChildAcademicSummary(
      student: student,
      cgpa: effectiveCgpa,
      overallAttendance: effectiveAttendance,
      totalClasses: 203,
      attendedClasses: 179,
      attendanceStatus: effectiveAttendance >= 85
          ? 'Good Standing'
          : effectiveAttendance >= 75
          ? 'Satisfactory'
          : 'Attendance Warning',
      subjectAttendances: subjectAttendances,
      subjectPerformances: subjectPerformances,
      upcomingExams: upcomingExams,
      upcomingAssignments: upcomingAssignments,
      smartInsights: smartInsights,
      announcements: announcements,
      recentActivities: recentActivities,
    );
  }
}
