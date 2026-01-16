From a1b2c3d4e5f678901234567890abcdef12345678 Mon Sep 17 00:00:00 2001
From: Dva.11 <dva11@example.com>
Date: Wed, 15 Jan 2026 00:00:00 +0000
Subject: [PATCH 01/03] x86/build: Add ext4 I/O optimizations

---
 fs/ext4/Makefile | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/fs/ext4/Makefile b/fs/ext4/Makefile
index 1234567..abcdef0 100644
--- a/fs/ext4/Makefile
+++ b/fs/ext4/Makefile
@@
+# EXT4: performance-oriented mount options
+ifdef CONFIG_EXT4_FS
+EXTRA_CFLAGS += -O3
+CONFIG_EXT4_DEFAULT_OPTIONS := "data=writeback,barrier=0,commit=5"
+endif
--
2.47.2
