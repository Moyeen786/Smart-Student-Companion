import 'package:flutter/material.dart';

// All display-only content is kept here so a future data adapter can replace it.
const sampleNotice = 'Preview with sample data · not connected to live records';
const _roles = ['Student', 'Faculty', 'Parent', 'Admin'];
const _nav = [
  'Overview',
  'Timetable',
  'Attendance',
  'Assignments',
  'Announcements',
];
const _classes = [
  ['09:00', 'Machine Learning', 'Dr. Meera Nair', 'C-204', 'done'],
  ['10:30', 'Compiler Design', 'Prof. R. Iyer', 'Lab 3', 'now'],
  ['12:00', 'Computer Networks', 'Dr. Kabir Shah', 'B-112', 'next'],
  ['14:00', 'Operating Systems', 'Prof. A. Das', 'A-301', 'upcoming'],
];

class WebPrototype extends StatefulWidget {
  const WebPrototype({super.key});
  @override
  State<WebPrototype> createState() => _WebPrototypeState();
}

class _WebPrototypeState extends State<WebPrototype> {
  String role = 'Student';
  String page = 'Sign in';
  String nav = 'Overview';
  bool signedIn = false;
  bool showPassword = false;
  bool loading = false;
  bool marked = false;
  final email = TextEditingController();
  final password = TextEditingController();

  void toast(String text) => ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(text),
      behavior: SnackBarBehavior.floating,
      backgroundColor: const Color(0xff172b50),
    ),
  );
  void enter() async {
    if (email.text.trim().isEmpty || password.text.isEmpty) {
      toast('Enter a username and password to continue');
      return;
    }
    setState(() => loading = true);
    await Future.delayed(const Duration(milliseconds: 550));
    if (mounted)
      setState(() {
        signedIn = true;
        loading = false;
        page = role;
      });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xfff5f8fc),
    body: signedIn ? _workspace() : _signIn(),
  );

  Widget _signIn() => LayoutBuilder(
    builder: (context, constraints) {
      final wide = constraints.maxWidth > 850;
      return Row(
        children: [
          if (wide)
            Expanded(
              child: Container(
                color: const Color(0xff102b5c),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: CustomPaint(painter: _GridPainter()),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 64,
                        vertical: 52,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _brand(light: true),
                          const Spacer(),
                          const Text(
                            'Your whole campus\nin one calm place.',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 46,
                              height: 1.13,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -1.2,
                            ),
                          ),
                          const SizedBox(height: 28),
                          for (final item in const [
                            ['◷', 'Live timetable, always in sync'],
                            ['✦', 'AI study support when you need it'],
                            ['⌘', 'A space for every campus role'],
                          ])
                            Padding(
                              padding: const EdgeInsets.only(bottom: 17),
                              child: Row(
                                children: [
                                  Container(
                                    width: 35,
                                    height: 35,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(.12),
                                      borderRadius: BorderRadius.circular(11),
                                    ),
                                    child: Center(
                                      child: Text(
                                        item[0],
                                        style: const TextStyle(
                                          color: Color(0xff77dccc),
                                          fontSize: 19,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 13),
                                  Text(
                                    item[1],
                                    style: const TextStyle(
                                      color: Color(0xffd6e4ff),
                                      fontSize: 15,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          const Spacer(),
                          const Text(
                            'Designed for the rhythm of campus life',
                            style: TextStyle(
                              color: Color(0xffa9bfdc),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(32),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 430),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (!wide) _brand(),
                      const SizedBox(height: 28),
                      const Text(
                        'Welcome back',
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w700,
                          color: Color(0xff10213d),
                          letterSpacing: -.7,
                        ),
                      ),
                      const SizedBox(height: 7),
                      const Text(
                        'Sign in to your campus workspace',
                        style: TextStyle(
                          color: Color(0xff718096),
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 29),
                      const Text(
                        'CONTINUE AS',
                        style: TextStyle(
                          color: Color(0xff7b8798),
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: const Color(0xffeef2f7),
                          borderRadius: BorderRadius.circular(13),
                        ),
                        child: Row(
                          children: _roles
                              .map(
                                (value) => Expanded(
                                  child: GestureDetector(
                                    onTap: () => setState(() => role = value),
                                    child: AnimatedContainer(
                                      duration: const Duration(
                                        milliseconds: 180,
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 10,
                                      ),
                                      decoration: BoxDecoration(
                                        color: role == value
                                            ? Colors.white
                                            : Colors.transparent,
                                        borderRadius: BorderRadius.circular(10),
                                        boxShadow: role == value
                                            ? [
                                                const BoxShadow(
                                                  color: Color(0x110b1f3a),
                                                  blurRadius: 7,
                                                  offset: Offset(0, 2),
                                                ),
                                              ]
                                            : [],
                                      ),
                                      child: Text(
                                        value,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: role == value
                                              ? const Color(0xff1d4ed8)
                                              : const Color(0xff68758a),
                                          fontWeight: role == value
                                              ? FontWeight.w600
                                              : FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ),
                      const SizedBox(height: 23),
                      _fieldLabel('Email or username'),
                      TextField(
                        controller: email,
                        decoration: _decoration(
                          'you@university.edu',
                          Icons.mail_outline,
                        ),
                      ),
                      const SizedBox(height: 17),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _fieldLabel('Password'),
                          TextButton(
                            onPressed: () => toast(
                              'Password reset is not connected in this preview',
                            ),
                            child: const Text(
                              'Forgot password?',
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xff2563eb),
                              ),
                            ),
                          ),
                        ],
                      ),
                      TextField(
                        controller: password,
                        obscureText: !showPassword,
                        decoration:
                            _decoration(
                              'Enter your password',
                              Icons.lock_outline,
                            ).copyWith(
                              suffixIcon: IconButton(
                                onPressed: () => setState(
                                  () => showPassword = !showPassword,
                                ),
                                icon: Icon(
                                  showPassword
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  size: 19,
                                ),
                              ),
                            ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 49,
                        child: FilledButton(
                          onPressed: loading ? null : enter,
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xff2563eb),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: loading
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  'Continue',
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                ),
                        ),
                      ),
                      const SizedBox(height: 19),
                      const Center(
                        child: Text(
                          'This is a design preview. No account or password is checked.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 11,
                            color: Color(0xff8a96a7),
                          ),
                        ),
                      ),
                      const SizedBox(height: 22),
                      Center(child: _notice()),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    },
  );
  Widget _workspace() => LayoutBuilder(
    builder: (context, box) {
      final wide = box.maxWidth > 850;
      final navItems = role == 'Parent'
          ? ['Overview', 'Performance', 'Attendance', 'Exams', 'Announcements']
          : _nav;
      return Row(
        children: [
          if (wide) _sidebar(navItems),
          Expanded(
            child: Column(
              children: [
                _topbar(wide),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                      horizontal: wide ? 38 : 20,
                      vertical: 25,
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1240),
                        child: _dashboard(wide),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    },
  );

  Widget _sidebar(List<String> navItems) => Container(
    width: 246,
    color: const Color(0xff102b5c),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 26, 20, 30),
          child: _brand(light: true),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: navItems.map((n) {
              final active = nav == n;
              return InkWell(
                onTap: () => setState(() => nav = n),
                borderRadius: BorderRadius.circular(11),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 4),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 13,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: active
                        ? Colors.white.withOpacity(.13)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _navIcon(n),
                        size: 18,
                        color: active
                            ? const Color(0xff7be0d1)
                            : const Color(0xffb6c8e4),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        n,
                        style: TextStyle(
                          color: active
                              ? Colors.white
                              : const Color(0xffc0d0e7),
                          fontSize: 13,
                          fontWeight: active
                              ? FontWeight.w600
                              : FontWeight.w400,
                        ),
                      ),
                      if (n == 'Announcements') const Spacer(),
                      if (n == 'Announcements') _countPill('2'),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const Spacer(),
        Container(
          margin: const EdgeInsets.all(15),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(.08),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.auto_awesome,
                color: Color(0xff73dfce),
                size: 19,
              ),
              const SizedBox(height: 10),
              const Text(
                'Study smarter',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Your AI study companion is ready.',
                style: TextStyle(
                  color: Color(0xffb8c9e1),
                  fontSize: 11,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () => setState(() => page = 'Assistant'),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  foregroundColor: const Color(0xff7be0d1),
                ),
                child: const Text(
                  'Open assistant  →',
                  style: TextStyle(fontSize: 11),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              _avatar('AS', size: 36),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      role == 'Student'
                          ? 'Aarav Sharma'
                          : role == 'Parent'
                          ? 'R. Sharma'
                          : role == 'Faculty'
                          ? 'Meera Nair'
                          : 'Campus Admin',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      role,
                      style: const TextStyle(
                        color: Color(0xffb6c8e4),
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => setState(() => signedIn = false),
                icon: const Icon(
                  Icons.logout,
                  color: Color(0xffb6c8e4),
                  size: 17,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );

  Widget _topbar(bool wide) => Container(
    height: 72,
    padding: EdgeInsets.symmetric(horizontal: wide ? 34 : 18),
    decoration: const BoxDecoration(
      color: Colors.white,
      border: Border(bottom: BorderSide(color: Color(0xffe9eef5))),
    ),
    child: Row(
      children: [
        if (!wide)
          IconButton(
            onPressed: () => _drawer(),
            icon: const Icon(Icons.menu_rounded),
          ),
        if (!wide) _brand(),
        if (wide)
          Text(
            '$role workspace',
            style: const TextStyle(color: Color(0xff8490a1), fontSize: 13),
          ),
        const Spacer(),
        _notice(),
        const SizedBox(width: 16),
        IconButton(
          onPressed: () => toast('You’re all caught up'),
          icon: const Icon(
            Icons.notifications_none_rounded,
            color: Color(0xff64748b),
          ),
        ),
        const SizedBox(width: 8),
        _avatar('AS', size: 35),
      ],
    ),
  );
  void _drawer() {
    final items = role == 'Parent'
        ? ['Overview', 'Performance', 'Attendance', 'Exams', 'Announcements']
        : _nav;
    showModalBottomSheet(
      context: context,
      builder: (c) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: items
              .map(
                (n) => ListTile(
                  title: Text(n),
                  onTap: () {
                    setState(() => nav = n);
                    Navigator.pop(c);
                  },
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  Widget _dashboard(bool wide) {
    if (page == 'Assistant') return _assistant();
    final parent = role == 'Parent',
        faculty = role == 'Faculty',
        admin = role == 'Admin';
    final greet = faculty
        ? 'Good morning, Meera'
        : parent
        ? 'Good morning, Mrs. Sharma'
        : admin
        ? 'Good morning, Admin'
        : 'Good morning, Aarav';
    final metrics = parent
        ? [
            ['8.6', 'CGPA', Icons.school_outlined, '+0.3 this semester'],
            [
              '82%',
              'Attendance',
              Icons.calendar_month_outlined,
              'Above 75% minimum',
            ],
            ['Oct 21', 'Next exam', Icons.event_outlined, 'Data Structures'],
            [
              '8 / 10',
              'Assignments',
              Icons.task_alt_outlined,
              '2 still in progress',
            ],
          ]
        : faculty
        ? [
            [
              '4',
              'Classes today',
              Icons.menu_book_outlined,
              'Next at 10:30 AM',
            ],
            [
              '86',
              'Attendance marked',
              Icons.how_to_reg_outlined,
              'Across 3 sections',
            ],
            [
              '12',
              'Pending evaluations',
              Icons.fact_check_outlined,
              'Due this week',
            ],
            [
              '3',
              'Leave requests',
              Icons.beach_access_outlined,
              'Awaiting review',
            ],
          ]
        : admin
        ? [
            ['2,486', 'Active users', Icons.group_outlined, 'Across campus'],
            ['12', 'Departments', Icons.apartment_outlined, '4 faculties'],
            [
              '8',
              'Pending approvals',
              Icons.pending_actions_outlined,
              'Needs attention',
            ],
            ['14', 'Open reports', Icons.flag_outlined, '6 new this week'],
          ]
        : [
            ['8.72', 'CGPA', Icons.school_outlined, 'Top 12% of class'],
            [
              '87.4%',
              'Attendance',
              Icons.calendar_month_outlined,
              '+2.4% this month',
            ],
            [
              '5',
              'Classes today',
              Icons.menu_book_outlined,
              'Next at 10:30 AM',
            ],
            ['3', 'Pending tasks', Icons.assignment_outlined, '1 due tomorrow'],
          ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    greet,
                    style: TextStyle(
                      fontSize: wide ? 27 : 23,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xff12213b),
                      letterSpacing: -.5,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    parent
                        ? 'Aarav Sharma · B.Tech Computer Science'
                        : faculty
                        ? 'Computer Science Department · Fall semester'
                        : admin
                        ? 'Campus overview · Tuesday, October 13, 2026'
                        : 'Tuesday, October 13 · Semester 5, 2026',
                    style: const TextStyle(
                      color: Color(0xff8792a2),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            if (wide) _notice(),
          ],
        ),
        const SizedBox(height: 22),
        if (!parent && !faculty && !admin) _hero(wide),
        if (!parent && !faculty && !admin) const SizedBox(height: 20),
        if (parent) _profileCard(),
        if (parent) const SizedBox(height: 19),
        _statGrid(metrics, wide),
        const SizedBox(height: 22),
        if (admin)
          _adminContent(wide)
        else if (faculty)
          _facultyContent(wide)
        else if (parent)
          _parentContent(wide)
        else
          _studentContent(wide),
      ],
    );
  }

  Widget _hero(bool wide) => Container(
    width: double.infinity,
    padding: EdgeInsets.all(wide ? 25 : 19),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(21),
      gradient: const LinearGradient(
        colors: [Color(0xff153d79), Color(0xff102b5c)],
      ),
      boxShadow: [
        BoxShadow(
          color: const Color(0xff173b6f).withOpacity(.16),
          blurRadius: 18,
          offset: const Offset(0, 8),
        ),
      ],
    ),
    child: Stack(
      children: [
        Positioned(
          right: 0,
          top: -40,
          bottom: -35,
          child: CustomPaint(
            size: const Size(300, 190),
            painter: _GridPainter(light: true),
          ),
        ),
        Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: const Color(0xff50d6bd).withOpacity(.16),
                borderRadius: BorderRadius.circular(13),
              ),
              child: const Icon(
                Icons.wb_sunny_outlined,
                color: Color(0xff6ce1cc),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'HAPPENING NOW · ENDS AT 11:20 AM',
                    style: TextStyle(
                      color: Color(0xff80dfd1),
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    wide
                        ? 'Compiler Design  ·  Lab 3'
                        : 'Compiler Design · Lab 3',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: wide ? 18 : 15,
                    ),
                  ),
                  const SizedBox(height: 3),
                  const Text(
                    'Prof. R. Iyer  ·  Block C',
                    style: TextStyle(color: Color(0xffc3d4ec), fontSize: 11),
                  ),
                ],
              ),
            ),
            if (wide)
              OutlinedButton.icon(
                onPressed: () => setState(() => page = 'Assistant'),
                icon: const Icon(Icons.auto_awesome, size: 16),
                label: const Text('Ask AI Assistant'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: BorderSide(color: Colors.white.withOpacity(.28)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
          ],
        ),
      ],
    ),
  );
  Widget _statGrid(List<List<dynamic>> values, bool wide) => LayoutBuilder(
    builder: (context, c) {
      final cols = c.maxWidth > 900
          ? 4
          : c.maxWidth > 560
          ? 2
          : 2;
      return GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: cols,
        crossAxisSpacing: 13,
        mainAxisSpacing: 13,
        childAspectRatio: c.maxWidth > 560 ? 2.25 : 1.6,
        children: values.map((v) => _stat(v)).toList(),
      );
    },
  );
  Widget _stat(List<dynamic> v) {
    final i = v[2] as IconData;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _card(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 31,
                height: 31,
                decoration: BoxDecoration(
                  color: const Color(0xffedf4ff),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(i, color: const Color(0xff2563eb), size: 16),
              ),
              const Spacer(),
              const Icon(Icons.more_horiz, color: Color(0xffaab3c0), size: 18),
            ],
          ),
          const Spacer(),
          Text(
            v[0] as String,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Color(0xff13233c),
              letterSpacing: -.5,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            v[1] as String,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Color(0xff46556c),
            ),
          ),
          const SizedBox(height: 3),
          Text(
            v[3] as String,
            style: const TextStyle(
              fontSize: 9,
              color: Color(0xff929dad),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _studentContent(bool wide) => Column(
    children: [
      _twoCol(wide, _schedule(), _quickActions()),
      const SizedBox(height: 18),
      _twoCol(wide, _attendanceChart(), _assignments()),
      const SizedBox(height: 18),
      _twoCol(wide, _events(), _announcements()),
    ],
  );
  Widget _twoCol(bool wide, Widget a, Widget b) => wide
      ? Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: a),
            const SizedBox(width: 16),
            Expanded(child: b),
          ],
        )
      : Column(children: [a, const SizedBox(height: 15), b]);

  Widget _schedule() => _panel(
    'Today’s timetable',
    'Tuesday · 5 classes',
    Column(
      children: _classes.map((c) {
        final state = c[4];
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              SizedBox(
                width: 48,
                child: Text(
                  c[0],
                  style: TextStyle(
                    color: state == 'done'
                        ? const Color(0xffa7b0bf)
                        : const Color(0xff59677c),
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
                  ),
                ),
              ),
              Container(
                width: 2,
                height: 39,
                decoration: BoxDecoration(
                  color: state == 'now'
                      ? const Color(0xff14b8a6)
                      : const Color(0xffe6ebf1),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      c[1],
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                        color: state == 'done'
                            ? const Color(0xff9ba5b2)
                            : const Color(0xff24334a),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${c[2]} · ${c[3]}',
                      style: const TextStyle(
                        color: Color(0xff909aaa),
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
              if (state == 'now')
                _tag('NOW', const Color(0xffdff8f2), const Color(0xff078c7a))
              else if (state == 'next')
                _tag('NEXT', const Color(0xffeaf1ff), const Color(0xff3f70ca))
              else if (state == 'done')
                const Icon(
                  Icons.check_circle,
                  color: Color(0xffa6d9c5),
                  size: 16,
                ),
            ],
          ),
        );
      }).toList(),
    ),
  );
  Widget _quickActions() => _panel(
    'Quick actions',
    'Everything you need in one tap',
    GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 3,
      childAspectRatio: 1.22,
      crossAxisSpacing: 7,
      mainAxisSpacing: 7,
      children:
          [
            ['Timetable', Icons.calendar_month_outlined],
            ['Attendance', Icons.fact_check_outlined],
            ['Notes', Icons.sticky_note_2_outlined],
            ['Assignments', Icons.assignment_outlined],
            ['QR ID', Icons.qr_code_2_outlined],
            ['AI study help', Icons.auto_awesome],
          ].map((a) {
            final ai = a[0] == 'AI study help';
            return InkWell(
              onTap: () => ai
                  ? setState(() => page = 'Assistant')
                  : toast('Opens in the full app'),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                decoration: BoxDecoration(
                  color: ai ? const Color(0xffedf9f7) : const Color(0xfff7f9fc),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: ai
                        ? const Color(0xffd3f0eb)
                        : const Color(0xffedf0f4),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      a[1] as IconData,
                      color: ai
                          ? const Color(0xff0f9e8c)
                          : const Color(0xff66809f),
                      size: 19,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      a[0] as String,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 9,
                        color: ai
                            ? const Color(0xff137f73)
                            : const Color(0xff637187),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
    ),
  );
  Widget _attendanceChart() => _panel(
    'Attendance trend',
    'Your consistency is paying off',
    Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: const [
            Text(
              '87.4%',
              style: TextStyle(
                fontSize: 27,
                fontWeight: FontWeight.w700,
                color: Color(0xff172844),
              ),
            ),
            SizedBox(width: 8),
            Padding(
              padding: EdgeInsets.only(bottom: 5),
              child: Text(
                '+2.4% this month',
                style: TextStyle(
                  fontSize: 10,
                  color: Color(0xff1a9d7b),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 105,
          child: CustomPaint(painter: _ChartPainter(), child: Container()),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: ['May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct']
              .map(
                (m) => Text(
                  m,
                  style: const TextStyle(color: Color(0xff9aa5b5), fontSize: 9),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 15),
        _subjectBar('Machine Learning', 92),
        _subjectBar('Compiler Design', 68, warning: true),
        _subjectBar('Networks', 84),
      ],
    ),
  );
  Widget _subjectBar(String name, int value, {bool warning = false}) => Padding(
    padding: const EdgeInsets.only(top: 11),
    child: Row(
      children: [
        Expanded(
          flex: 3,
          child: Text(
            name,
            style: const TextStyle(fontSize: 10, color: Color(0xff65738a)),
          ),
        ),
        Expanded(
          flex: 4,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: LinearProgressIndicator(
              value: value / 100,
              minHeight: 6,
              backgroundColor: const Color(0xffeff2f6),
              color: warning
                  ? const Color(0xfff0ae44)
                  : const Color(0xff18b4a0),
            ),
          ),
        ),
        const SizedBox(width: 9),
        Text(
          '$value%',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: warning ? const Color(0xffd28a17) : const Color(0xff526177),
          ),
        ),
      ],
    ),
  );
  Widget _assignments() => _panel(
    'Assignments',
    '3 tasks need your attention',
    Column(
      children: [
        _assignment(
          'Research paper outline',
          'Machine Learning',
          'Due tomorrow',
          .72,
          urgent: true,
        ),
        _assignment(
          'Parser implementation',
          'Compiler Design',
          'Due Oct 16',
          .42,
        ),
        _assignment('Subnetting worksheet', 'Networks', 'Due Oct 18', .1),
      ],
    ),
  );
  Widget _assignment(
    String title,
    String sub,
    String due,
    double prog, {
    bool urgent = false,
  }) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 9),
    child: Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 11,
                      color: Color(0xff33435b),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    sub,
                    style: const TextStyle(
                      fontSize: 9,
                      color: Color(0xff909aaa),
                    ),
                  ),
                ],
              ),
            ),
            _tag(
              due,
              urgent ? const Color(0xfffff1e8) : const Color(0xffedf3ff),
              urgent ? const Color(0xffdd7544) : const Color(0xff5b78a5),
            ),
          ],
        ),
        const SizedBox(height: 10),
        LinearProgressIndicator(
          value: prog,
          minHeight: 4,
          borderRadius: BorderRadius.circular(4),
          backgroundColor: const Color(0xffedf1f5),
          color: urgent ? const Color(0xfff0a64d) : const Color(0xff5089e9),
        ),
      ],
    ),
  );
  Widget _events() => _panel(
    'Coming up',
    'Mark your calendar',
    Column(
      children: [
        _event(
          '18',
          'OCT',
          'Hackathon 2026',
          'Innovation Hub · 9:00 AM',
          const Color(0xffe9f1ff),
        ),
        _event(
          '21',
          'OCT',
          'Data Structures exam',
          'Examination Hall A · 10:00 AM',
          const Color(0xfffff2e4),
        ),
        _event(
          '24',
          'OCT',
          'TechTalk: Building with AI',
          'Auditorium · 4:30 PM',
          const Color(0xffe7f8f3),
        ),
      ],
    ),
  );
  Widget _event(
    String day,
    String month,
    String title,
    String detail,
    Color tint,
  ) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 7),
    child: Row(
      children: [
        Container(
          width: 43,
          height: 45,
          decoration: BoxDecoration(
            color: tint,
            borderRadius: BorderRadius.circular(11),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                day,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  color: Color(0xff24334a),
                ),
              ),
              Text(
                month,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 8,
                  color: Color(0xff718096),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 11),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 11,
                  color: Color(0xff34435a),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                detail,
                style: const TextStyle(fontSize: 9, color: Color(0xff8e9aaa)),
              ),
            ],
          ),
        ),
        const Icon(Icons.chevron_right, size: 17, color: Color(0xffa8b1bd)),
      ],
    ),
  );
  Widget _announcements() => _panel(
    'Campus updates',
    'The latest from your campus',
    Column(
      children: [
        _announcement(
          'Mid-semester examination schedule',
          'Academic Office · 2 hours ago',
          'ACADEMIC',
          const Color(0xffeaf1ff),
          const Color(0xff4b72bf),
        ),
        _announcement(
          'Library extended hours this week',
          'Central Library · Yesterday',
          'CAMPUS',
          const Color(0xffe7f7f3),
          const Color(0xff188b7c),
        ),
        _announcement(
          'Hackathon 2026 registrations open',
          'Student Council · Oct 10',
          'EVENT',
          const Color(0xfffff3e8),
          const Color(0xffce8b33),
        ),
      ],
    ),
  );
  Widget _announcement(
    String title,
    String by,
    String tag,
    Color bg,
    Color fg,
  ) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 9),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 8,
          height: 8,
          margin: const EdgeInsets.only(top: 5),
          decoration: BoxDecoration(color: fg, shape: BoxShape.circle),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 11,
                  color: Color(0xff33435b),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                by,
                style: const TextStyle(fontSize: 9, color: Color(0xff929dad)),
              ),
            ],
          ),
        ),
        _tag(tag, bg, fg),
      ],
    ),
  );

  Widget _facultyContent(bool wide) => Column(
    children: [
      _twoCol(
        wide,
        _panel(
          'Today’s teaching schedule',
          'Tuesday · Computer Science',
          Column(
            children: _classes
                .take(3)
                .map(
                  (c) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 49,
                          child: Text(
                            c[0],
                            style: const TextStyle(
                              color: Color(0xff718096),
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                c[1],
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                'CS · Section A · ${c[3]}',
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Color(0xff8b97a8),
                                ),
                              ),
                            ],
                          ),
                        ),
                        marked
                            ? _tag(
                                'MARKED',
                                const Color(0xffe7f8f0),
                                const Color(0xff229267),
                              )
                            : OutlinedButton(
                                onPressed: () => _attendanceDialog(),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 11,
                                  ),
                                  visualDensity: VisualDensity.compact,
                                  side: const BorderSide(
                                    color: Color(0xffdce5f0),
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(9),
                                  ),
                                ),
                                child: const Text(
                                  'Mark attendance',
                                  style: TextStyle(fontSize: 10),
                                ),
                              ),
                      ],
                    ),
                  ),
                )
                .toList(),
          ),
        ),
        _panel(
          'Leave requests',
          '3 awaiting your review',
          Column(
            children: [
              _leave('Ananya Rao', 'Oct 16–17', 'Medical leave'),
              _leave('Rohit Menon', 'Oct 20', 'Personal leave'),
              _leave('Priya Shah', 'Oct 24–25', 'Family event'),
            ],
          ),
        ),
      ),
      const SizedBox(height: 16),
      _twoCol(wide, _courses(), _quickShortcuts()),
    ],
  );
  Widget _leave(String n, String date, String reason) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 9),
    child: Row(
      children: [
        _avatar(n.split(' ').map((e) => e[0]).join(), size: 33),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                n,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '$reason · $date',
                style: const TextStyle(fontSize: 9, color: Color(0xff8c98a8)),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: () => toast('Request declined'),
          icon: const Icon(Icons.close, color: Color(0xffdd6565), size: 17),
        ),
        IconButton(
          onPressed: () => toast('Request approved'),
          icon: const Icon(Icons.check, color: Color(0xff2fa57a), size: 18),
        ),
      ],
    ),
  );
  Widget _courses() => _panel(
    'Your courses',
    'Syllabus progress',
    Column(
      children: [
        _course('Machine Learning', 72, 'CS 501'),
        _course('Compiler Design', 58, 'CS 503'),
        _course('Computer Networks', 84, 'CS 505'),
        _course('Operating Systems', 91, 'CS 507'),
      ],
    ),
  );
  Widget _course(String name, int progress, String code) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 9),
    child: Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                name,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Text(
              code,
              style: const TextStyle(fontSize: 9, color: Color(0xff909aaa)),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: LinearProgressIndicator(
                value: progress / 100,
                minHeight: 5,
                borderRadius: BorderRadius.circular(5),
                backgroundColor: const Color(0xffedf1f5),
                color: const Color(0xff3d84e8),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '$progress%',
              style: const TextStyle(fontSize: 9, color: Color(0xff65738a)),
            ),
          ],
        ),
      ],
    ),
  );
  Widget _quickShortcuts() => _panel(
    'Quick shortcuts',
    'Common faculty actions',
    Column(
      children: [
        for (final s in [
          'Post announcement',
          'Create assignment',
          'Lost & Found',
        ])
          ListTile(
            contentPadding: EdgeInsets.zero,
            dense: true,
            leading: const Icon(
              Icons.arrow_outward,
              size: 16,
              color: Color(0xff4b78b8),
            ),
            title: Text(
              s,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
            ),
            trailing: const Icon(
              Icons.chevron_right,
              size: 16,
              color: Color(0xffa2adbb),
            ),
            onTap: () => toast('Opens in the full app'),
          ),
      ],
    ),
  );

  Widget _profileCard() => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: const Color(0xffe7edf5)),
    ),
    child: Row(
      children: [
        _avatar('AS', size: 48),
        const SizedBox(width: 13),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Aarav Sharma',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: Color(0xff24334a),
                ),
              ),
              SizedBox(height: 3),
              Text(
                'CS21B047 · B.Tech Computer Science · Semester 5',
                style: TextStyle(fontSize: 10, color: Color(0xff8995a5)),
              ),
            ],
          ),
        ),
        _tag('VIEW ONLY', const Color(0xffeef3fa), const Color(0xff60738e)),
      ],
    ),
  );
  Widget _parentContent(bool wide) => Column(
    children: [
      _twoCol(
        wide,
        _cgpaChart(),
        _panel(
          'Subject attendance',
          '75% minimum requirement',
          Column(
            children: [
              _subjectBar('Machine Learning', 92),
              _subjectBar('Compiler Design', 68, warning: true),
              _subjectBar('Networks', 84),
              _subjectBar('Operating Systems', 79),
            ],
          ),
        ),
      ),
      const SizedBox(height: 17),
      _twoCol(
        wide,
        _panel(
          'Upcoming exams & deadlines',
          'October 2026',
          Column(
            children: [
              _event(
                '21',
                'OCT',
                'Data Structures',
                'End semester exam · 10:00 AM',
                const Color(0xfffff2e4),
              ),
              _event(
                '25',
                'OCT',
                'Compiler Design',
                'Assignment 3 deadline',
                const Color(0xffeaf1ff),
              ),
              _event(
                '29',
                'OCT',
                'Computer Networks',
                'Mid semester exam · 2:00 PM',
                const Color(0xffe7f8f3),
              ),
            ],
          ),
        ),
        _panel(
          'Progress summary',
          'A note from the academic team',
          const Text(
            'Aarav is making steady progress this semester. His strongest area is Machine Learning, with consistent attendance and thoughtful class participation. Compiler Design would benefit from a little extra practice; attendance is currently below the 75% minimum.',
            style: TextStyle(
              fontSize: 11,
              height: 1.7,
              color: Color(0xff64748b),
            ),
          ),
        ),
      ),
      const SizedBox(height: 17),
      _panel(
        'Notices for parents',
        'Updates from the university',
        Column(
          children: [
            _announcement(
              'Parent–faculty consultations · Oct 26',
              'Academic Office · Oct 12',
              'NOTICE',
              const Color(0xffeaf1ff),
              const Color(0xff4b72bf),
            ),
            _announcement(
              'Mid-semester results published',
              'Examination Cell · Oct 8',
              'ACADEMIC',
              const Color(0xffe7f7f3),
              const Color(0xff188b7c),
            ),
          ],
        ),
      ),
    ],
  );
  Widget _cgpaChart() => _panel(
    'CGPA by semester',
    'Aarav’s academic journey',
    Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '8.6',
          style: TextStyle(
            fontSize: 27,
            fontWeight: FontWeight.w700,
            color: Color(0xff172844),
          ),
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 110,
          child: CustomPaint(
            painter: _ChartPainter(values: [.55, .68, .63, .79, .85]),
            child: Container(),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: ['Sem 1', 'Sem 2', 'Sem 3', 'Sem 4', 'Sem 5']
              .map(
                (m) => Text(
                  m,
                  style: const TextStyle(fontSize: 9, color: Color(0xff929dad)),
                ),
              )
              .toList(),
        ),
      ],
    ),
  );

  Widget _adminContent(bool wide) => Column(
    children: [
      _twoCol(
        wide,
        _panel(
          'Department attendance',
          'Today · all departments',
          Column(
            children: [
              _subjectBar('Computer Science', 88),
              _subjectBar('Electronics', 82),
              _subjectBar('Mechanical', 76),
              _subjectBar('Civil', 91),
              _subjectBar('Business', 85),
            ],
          ),
        ),
        _panel(
          'Campus modules',
          'Quick access',
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ['Library', Icons.local_library_outlined],
              ['Placements', Icons.work_outline],
              ['Events', Icons.event_outlined],
              ['Lost & Found', Icons.inventory_2_outlined],
            ].map((m) => _module(m[0] as String, m[1] as IconData)).toList(),
          ),
        ),
      ),
      const SizedBox(height: 16),
      _twoCol(
        wide,
        _usersPanel(),
        _panel(
          'Activity log',
          'Recent campus activity',
          Column(
            children: [
              _activity('New student account approved', 'CS21B089 · 8 min ago'),
              _activity(
                'Announcement published',
                'Library hours update · 1 hr ago',
              ),
              _activity('Leave request submitted', 'Ananya Rao · 2 hrs ago'),
              _activity('Lost item reported', 'Wireless earbuds · 3 hrs ago'),
            ],
          ),
        ),
      ),
      const SizedBox(height: 16),
      _panel(
        'Announcements',
        'Campus-wide updates',
        Row(
          children: [
            const Expanded(
              child: Text(
                'Create an announcement for students, faculty, and families.',
                style: TextStyle(fontSize: 11, color: Color(0xff738197)),
              ),
            ),
            FilledButton.icon(
              onPressed: () => _announcementDialog(),
              icon: const Icon(Icons.add, size: 16),
              label: const Text('New announcement'),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xff2563eb),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(9),
                ),
              ),
            ),
          ],
        ),
      ),
    ],
  );
  Widget _module(String name, IconData icon) => InkWell(
    onTap: () => toast('Opens in the full app'),
    child: Container(
      width: 105,
      height: 80,
      decoration: BoxDecoration(
        color: const Color(0xfff6f8fb),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xffeaf0f6)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: const Color(0xff56779f), size: 19),
          const SizedBox(height: 8),
          Text(
            name,
            style: const TextStyle(
              fontSize: 9,
              color: Color(0xff5a687d),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    ),
  );
  Widget _usersPanel() => _panel(
    'Users & roles',
    '2,486 campus accounts',
    Column(
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                decoration: _decoration('Search users', Icons.search).copyWith(
                  isDense: true,
                  contentPadding: const EdgeInsets.all(10),
                ),
              ),
            ),
            const SizedBox(width: 8),
            DropdownButton<String>(
              value: 'All roles',
              items: ['All roles', 'Student', 'Faculty', 'Parent', 'Admin']
                  .map(
                    (e) => DropdownMenuItem(
                      value: e,
                      child: Text(e, style: const TextStyle(fontSize: 10)),
                    ),
                  )
                  .toList(),
              onChanged: (_) {},
              underline: const SizedBox(),
            ),
          ],
        ),
        const SizedBox(height: 7),
        for (final u in [
          ['Ananya Rao', 'CS21B089', 'Student', 'Active'],
          ['Rohit Menon', 'EC22B014', 'Student', 'Pending'],
          ['Meera Nair', 'FAC0042', 'Faculty', 'Active'],
          ['R. Sharma', 'PAR0031', 'Parent', 'Active'],
        ])
          _userRow(u[0], u[1], u[2], u[3]),
      ],
    ),
  );
  Widget _userRow(String n, String id, String role, String status) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Row(
      children: [
        _avatar(n.split(' ').map((e) => e[0]).join(), size: 29),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                n,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '$id · $role',
                style: const TextStyle(fontSize: 8, color: Color(0xff909aaa)),
              ),
            ],
          ),
        ),
        _tag(
          status,
          status == 'Active'
              ? const Color(0xffeaf8f2)
              : const Color(0xfffff4e4),
          status == 'Active'
              ? const Color(0xff258b67)
              : const Color(0xffbd8428),
        ),
        PopupMenuButton<String>(
          padding: EdgeInsets.zero,
          icon: const Icon(Icons.more_vert, size: 16, color: Color(0xff8793a3)),
          itemBuilder: (_) => ['View profile', 'Change role', 'Suspend']
              .map(
                (e) => PopupMenuItem(
                  value: e,
                  child: Text(e, style: const TextStyle(fontSize: 11)),
                ),
              )
              .toList(),
          onSelected: (v) => toast('$v · preview only'),
        ),
      ],
    ),
  );
  Widget _activity(String title, String detail) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 9),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 8,
          height: 8,
          margin: const EdgeInsets.only(top: 5),
          decoration: const BoxDecoration(
            color: Color(0xff50bda8),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 10,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                detail,
                style: const TextStyle(fontSize: 9, color: Color(0xff8e9aaa)),
              ),
            ],
          ),
        ),
      ],
    ),
  );

  Widget _assistant() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        'AI Study Assistant',
        style: TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 25,
          color: Color(0xff172844),
        ),
      ),
      const SizedBox(height: 5),
      const Text(
        'Fixed sample replies · no AI model is connected',
        style: TextStyle(color: Color(0xff8995a5), fontSize: 12),
      ),
      const SizedBox(height: 18),
      Wrap(
        spacing: 8,
        children:
            [
                  'Machine Learning',
                  'Compiler Design',
                  'Computer Networks',
                  'Operating Systems',
                ]
                .map(
                  (s) => ActionChip(
                    label: Text(s, style: const TextStyle(fontSize: 10)),
                    onPressed: () => toast('$s selected'),
                  ),
                )
                .toList(),
      ),
      const SizedBox(height: 18),
      Container(
        width: double.infinity,
        height: 380,
        padding: const EdgeInsets.all(25),
        decoration: _card(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: const Color(0xffeaf8f5),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.auto_awesome, color: Color(0xff159e8b)),
            ),
            const SizedBox(height: 13),
            const Text(
              'What would you like to learn today?',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 16,
                color: Color(0xff26364d),
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Pick a starting point or ask your own question.',
              style: TextStyle(fontSize: 11, color: Color(0xff8a96a7)),
            ),
            const SizedBox(height: 23),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              alignment: WrapAlignment.center,
              children:
                  ['Explain this topic', 'Summarize my notes', 'Generate MCQs']
                      .map(
                        (s) => OutlinedButton(
                          onPressed: () => _reply(s),
                          style: OutlinedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(s, style: const TextStyle(fontSize: 10)),
                        ),
                      )
                      .toList(),
            ),
          ],
        ),
      ),
      const SizedBox(height: 14),
      TextField(
        maxLines: 2,
        minLines: 1,
        onSubmitted: _reply,
        decoration:
            _decoration(
              'Ask a study question…',
              Icons.chat_bubble_outline,
            ).copyWith(
              suffixIcon: IconButton(
                onPressed: () => _reply('Explain gradient descent'),
                icon: const Icon(Icons.arrow_upward, color: Color(0xff2563eb)),
              ),
            ),
      ),
    ],
  );
  void _reply(String prompt) {
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(prompt),
        content: const Text(
          'Gradient descent is an optimization method that iteratively adjusts model parameters in the direction that reduces the loss function. Each update takes a small step opposite to the gradient.\n\nSample response · no AI model connected.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _attendanceDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (c) {
        final names = [
          'Ananya Rao',
          'Rohit Menon',
          'Priya Shah',
          'Kabir Joshi',
          'Nisha Patel',
          'Dev Malhotra',
          'Isha Kulkarni',
          'Arjun Das',
        ];
        final present = List<bool>.filled(names.length, true);
        return StatefulBuilder(
          builder: (c, setD) => AlertDialog(
            title: const Text('Mark attendance'),
            content: SizedBox(
              width: 390,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Compiler Design · CS · Section A',
                    style: TextStyle(color: Color(0xff738197), fontSize: 12),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    decoration: _decoration('Search roster', Icons.search),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    '${present.where((e) => e).length} of ${names.length} present',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(
                    height: 290,
                    child: ListView.builder(
                      itemCount: names.length,
                      itemBuilder: (context, i) => ListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          names[i],
                          style: const TextStyle(fontSize: 12),
                        ),
                        trailing: Switch(
                          value: present[i],
                          activeColor: const Color(0xff22c55e),
                          onChanged: (v) => setD(() => present[i] = v),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(c, false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(c, true),
                child: const Text('Save attendance'),
              ),
            ],
          ),
        );
      },
    );
    if (result == true) {
      setState(() => marked = true);
      toast('Attendance saved · sample preview');
    }
  }

  Future<void> _announcementDialog() async {
    final title = TextEditingController(), body = TextEditingController();
    await showDialog(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('New announcement'),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: title,
                decoration: _decoration('Announcement title', Icons.title),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: body,
                maxLines: 4,
                decoration: _decoration('Write a message…', Icons.notes),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (title.text.trim().isEmpty || body.text.trim().isEmpty) {
                toast('Add a title and message');
                return;
              }
              Navigator.pop(c);
              toast('Announcement published · preview only');
            },
            child: const Text('Publish'),
          ),
        ],
      ),
    );
  }

  Widget _panel(String title, String subtitle, Widget child) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(17),
    decoration: _card(),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Color(0xff26364d),
                ),
              ),
            ),
            const Icon(Icons.more_horiz, color: Color(0xff9aa5b5), size: 19),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: const TextStyle(fontSize: 9, color: Color(0xff919cab)),
        ),
        const SizedBox(height: 12),
        child,
      ],
    ),
  );
  BoxDecoration _card() => BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(17),
    border: Border.all(color: const Color(0xffe9eef4)),
    boxShadow: const [
      BoxShadow(color: Color(0x080d2140), blurRadius: 14, offset: Offset(0, 4)),
    ],
  );
  Widget _brand({bool light = false}) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: const Color(0xff14b8a6),
          borderRadius: BorderRadius.circular(11),
        ),
        child: const Icon(Icons.school_rounded, color: Colors.white, size: 19),
      ),
      const SizedBox(width: 10),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'campusly',
            style: TextStyle(
              color: light ? Colors.white : const Color(0xff172844),
              fontWeight: FontWeight.w700,
              fontSize: 16,
              letterSpacing: -.4,
            ),
          ),
          Text(
            'SMART STUDENT COMPANION',
            style: TextStyle(
              color: light ? const Color(0xffb1c7e4) : const Color(0xff8e9aac),
              fontSize: 7,
              letterSpacing: 1,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    ],
  );
  Widget _notice() => Tooltip(
    message: sampleNotice,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xfff0f7ff),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xffe0ebf8)),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.info_outline, size: 12, color: Color(0xff6080a7)),
          SizedBox(width: 5),
          Text(
            'Preview with sample data',
            style: TextStyle(
              fontSize: 9,
              color: Color(0xff607895),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    ),
  );
  Widget _avatar(String initials, {double size = 32}) => Container(
    width: size,
    height: size,
    alignment: Alignment.center,
    decoration: const BoxDecoration(
      shape: BoxShape.circle,
      gradient: LinearGradient(colors: [Color(0xffcce8e7), Color(0xffdce5fb)]),
    ),
    child: Text(
      initials,
      style: TextStyle(
        fontWeight: FontWeight.w700,
        fontSize: size * .31,
        color: const Color(0xff315475),
      ),
    ),
  );
  Widget _tag(String label, Color bg, Color fg) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
    decoration: BoxDecoration(
      color: bg,
      borderRadius: BorderRadius.circular(6),
    ),
    child: Text(
      label,
      style: TextStyle(
        color: fg,
        fontSize: 8,
        fontWeight: FontWeight.w700,
        letterSpacing: .25,
      ),
    ),
  );
  Widget _countPill(String s) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
    decoration: BoxDecoration(
      color: const Color(0xff14b8a6),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Text(
      s,
      style: const TextStyle(
        fontSize: 9,
        color: Colors.white,
        fontWeight: FontWeight.w700,
      ),
    ),
  );
  Widget _fieldLabel(String s) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(
      s,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: Color(0xff34435a),
      ),
    ),
  );
  InputDecoration _decoration(String hint, IconData icon) => InputDecoration(
    hintText: hint,
    prefixIcon: Icon(icon, size: 18, color: const Color(0xff98a4b3)),
    hintStyle: const TextStyle(fontSize: 12, color: Color(0xffa2adbb)),
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(11),
      borderSide: const BorderSide(color: Color(0xffe3e9f0)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(11),
      borderSide: const BorderSide(color: Color(0xffe3e9f0)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(11),
      borderSide: const BorderSide(color: Color(0xff7ea9ef)),
    ),
  );
  IconData _navIcon(String n) => switch (n) {
    'Overview' => Icons.grid_view_rounded,
    'Timetable' => Icons.calendar_month_outlined,
    'Attendance' => Icons.fact_check_outlined,
    'Assignments' => Icons.assignment_outlined,
    'Announcements' => Icons.campaign_outlined,
    'Performance' => Icons.show_chart,
    'Exams' => Icons.event_outlined,
    _ => Icons.circle_outlined,
  };
}

class _GridPainter extends CustomPainter {
  final bool light;
  _GridPainter({this.light = false});
  @override
  void paint(Canvas c, Size s) {
    final p = Paint()
      ..color = (light ? Colors.white : const Color(0xff5b84c1)).withOpacity(
        .10,
      )
      ..strokeWidth = 1;
    for (double x = 0; x < s.width; x += 26)
      c.drawLine(Offset(x, 0), Offset(x, s.height), p);
    for (double y = 0; y < s.height; y += 26)
      c.drawLine(Offset(0, y), Offset(s.width, y), p);
  }

  @override
  bool shouldRepaint(covariant _GridPainter old) => old.light != light;
}

class _ChartPainter extends CustomPainter {
  final List<double> values;
  _ChartPainter({this.values = const [.43, .59, .53, .69, .75, .67, .86]});
  @override
  void paint(Canvas c, Size s) {
    final grid = Paint()
      ..color = const Color(0xffedf1f5)
      ..strokeWidth = 1;
    for (int i = 0; i < 4; i++) {
      final y = s.height * i / 3;
      c.drawLine(Offset(0, y), Offset(s.width, y), grid);
    }
    final points = <Offset>[];
    for (int i = 0; i < values.length; i++)
      points.add(
        Offset(s.width * i / (values.length - 1), s.height * (1 - values[i])),
      );
    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (int i = 1; i < points.length; i++)
      path.lineTo(points[i].dx, points[i].dy);
    final fill = Path.from(path)
      ..lineTo(s.width, s.height)
      ..lineTo(0, s.height)
      ..close();
    c.drawPath(
      fill,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0x334cb9a5), Color(0x004cb9a5)],
        ).createShader(Offset.zero & s),
    );
    c.drawPath(
      path,
      Paint()
        ..color = const Color(0xff24a991)
        ..strokeWidth = 2.5
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
    for (final p in points) c.drawCircle(p, 3, Paint()..color = Colors.white);
    for (final p in points)
      c.drawCircle(p, 2, Paint()..color = const Color(0xff24a991));
  }

  @override
  bool shouldRepaint(covariant _ChartPainter old) => old.values != values;
}
