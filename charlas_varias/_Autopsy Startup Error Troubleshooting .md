> From: https://gemini.google.com/app/84722556d538ca38

# you asked

org.netbeans.InvalidException: StandardModule:org.sleuthkit.autopsy.core jarFile: /opt/autopsy/autopsy/modules/org-sleuthkit-autopsy-core.jar: java.lang.IllegalArgumentException: java.lang.reflect.InvocationTargetException

---

# gemini response

This is a classic NetBeans platform error indicating that Autopsy failed to launch because its core GUI module crashed during startup. 

Because Autopsy is built on the NetBeans Rich Client Platform (RCP), it relies on a modular architecture. Here is exactly what this snippet is telling us:
* **`StandardModule:org.sleuthkit.autopsy.core`**: The framework tried to load Autopsy's main core module.
* **`/opt/autopsy/...`**: This confirms you are running Autopsy on a Linux system (likely Kali Linux or a manual install).
* **`InvocationTargetException`**: This is the smoking gun. It is a "wrapper" exception in Java that means a method was executed, but that method internally threw an error. **The actual root cause of your crash is hidden just below this line in your logs.**

Here are the most common reasons this happens on Linux and how to fix them:

### 1. Incompatible or Missing Java Version (Most Likely)
Autopsy heavily relies on **JavaFX** for its user interface. Standard Linux repositories often install OpenJDK *without* the JavaFX modules. If the core module tries to load a UI element and JavaFX is missing, it throws this exact reflection error.
* Autopsy generally requires **Java 11** or **Java 17** (depending on the version of Autopsy you are running).
* You typically need a "Full" JDK that includes JavaFX, such as the **BellSoft Liberica JDK (Full version)**, or you need to install OpenJFX separately alongside OpenJDK (`sudo apt install openjfx`).

### 2. Corrupted NetBeans User Cache
Sometimes the local configuration files get corrupted, preventing the core module from initializing properly. 
* You can force Autopsy to rebuild its cache by resetting your user directory. 
* Open your terminal and rename the hidden Autopsy folder in your home directory: 
  `mv ~/.autopsy ~/.autopsy_backup`
* Try launching Autopsy again.

### 3. Missing Sleuth Kit Dependencies
Autopsy is the graphical front-end for The Sleuth Kit (TSK). If the underlying C/C++ TSK libraries or their Java Native Interface (JNI) bindings are missing, mismatched, or compiled incorrectly for your specific Linux kernel, the core module will fail to load.

***

To know for sure exactly which of these three things is happening, we need to look past the wrapper exception. 

Are you able to navigate to your Autopsy log file (usually located at `~/.autopsy/dev/var/log/messages.log` or `~/.autopsy/<version_number>/var/log/messages.log`) and find the **"Caused by:"** line immediately following the error you pasted?

---

# you asked

Tengo este problema.

OpenJDK 64-Bit Server VM warning: Options -Xverify:none and -noverify were deprecated in JDK 13 and will likely be removed in a future release.
abr 08, 2026 6:49:53 P. M. org.netbeans.ProxyURLStreamHandlerFactory register
GRAVE: No way to find original stream handler for jar protocol
java.lang.reflect.InaccessibleObjectException: Unable to make field transient java.net.URLStreamHandler java.net.URL.handler accessible: module java.base does not "opens java.net" to unnamed module @677327b6
	at java.base/java.lang.reflect.AccessibleObject.throwInaccessibleObjectException(AccessibleObject.java:343)
	at java.base/java.lang.reflect.AccessibleObject.checkCanSetAccessible(AccessibleObject.java:319)
	at java.base/java.lang.reflect.AccessibleObject.checkCanSetAccessible(AccessibleObject.java:267)
	at java.base/java.lang.reflect.Field.checkCanSetAccessible(Field.java:207)
	at java.base/java.lang.reflect.Field.setAccessible(Field.java:201)
	at org.netbeans.ProxyURLStreamHandlerFactory.register(ProxyURLStreamHandlerFactory.java:59)
	at org.netbeans.JarClassLoader.<clinit>(JarClassLoader.java:117)
	at org.netbeans.MainImpl.execute(MainImpl.java:153)
	at org.netbeans.MainImpl.main(MainImpl.java:60)
	at org.netbeans.Main.main(Main.java:58)

java.lang.UnsupportedOperationException: Setting a Security Manager is not supported
	at java.base/java.lang.System.setSecurityManager(System.java:304)
	at org.netbeans.TopSecurityManager.install(TopSecurityManager.java:525)
	at org.netbeans.core.NbLifecycleManager.advancePolicy(NbLifecycleManager.java:69)
	at org.netbeans.core.GuiRunLevel.run(GuiRunLevel.java:84)
	at org.netbeans.core.startup.Main.start(Main.java:295)
	at org.netbeans.core.startup.TopThreadGroup.run(TopThreadGroup.java:98)
	at java.base/java.lang.Thread.run(Thread.java:1516)

 > cat ~/.autopsy/dev/var/log/messages.log | grep -Ei "^[a-z]"
WARNING [org.netbeans.core.startup.NbEvents]: The extension /opt/autopsy/autopsy/modules/ext/commons-digester-1.8.1.jar may be multiply loaded by modules: [/opt/autopsy/autopsy/modules/org-sleuthkit-autopsy-keywordsearch.jar, /opt/autopsy/autopsy/modules/org-sleuthkit-autopsy-core.jar]; see: http://www.netbeans.org/download/dev/javadoc/org-openide-modules/org/openide/modules/doc-files/classpath.html#class-path
WARNING [org.netbeans.core.startup.NbEvents]: The extension /opt/autopsy/autopsy/modules/ext/xmpcore-5.1.3.jar may be multiply loaded by modules: [/opt/autopsy/autopsy/modules/org-sleuthkit-autopsy-keywordsearch.jar, /opt/autopsy/autopsy/modules/org-sleuthkit-autopsy-core.jar, /opt/autopsy/autopsy/modules/org-sleuthkit-autopsy-Tika.jar]; see: http://www.netbeans.org/download/dev/javadoc/org-openide-modules/org/openide/modules/doc-files/classpath.html#class-path
WARNING [org.netbeans.core.startup.NbEvents]: The extension /opt/autopsy/autopsy/modules/ext/jericho-html-3.3.jar may be multiply loaded by modules: [/opt/autopsy/autopsy/modules/org-sleuthkit-autopsy-keywordsearch.jar, /opt/autopsy/autopsy/modules/org-sleuthkit-autopsy-core.jar]; see: http://www.netbeans.org/download/dev/javadoc/org-openide-modules/org/openide/modules/doc-files/classpath.html#class-path
WARNING [org.netbeans.core.startup.NbEvents]: The extension /opt/autopsy/autopsy/modules/ext/commons-validator-1.6.jar may be multiply loaded by modules: [/opt/autopsy/autopsy/modules/org-sleuthkit-autopsy-thunderbirdparser.jar, /opt/autopsy/autopsy/modules/org-sleuthkit-autopsy-core.jar]; see: http://www.netbeans.org/download/dev/javadoc/org-openide-modules/org/openide/modules/doc-files/classpath.html#class-path
WARNING [org.netbeans.core.startup.NbEvents]: The extension /opt/autopsy/autopsy/modules/ext/commons-logging-1.2.jar may be multiply loaded by modules: [/opt/autopsy/autopsy/modules/org-sleuthkit-autopsy-keywordsearch.jar, /opt/autopsy/autopsy/modules/org-sleuthkit-autopsy-core.jar]; see: http://www.netbeans.org/download/dev/javadoc/org-openide-modules/org/openide/modules/doc-files/classpath.html#class-path
WARNING [org.netbeans.core.startup.NbEvents]: The extension /opt/autopsy/autopsy/modules/ext/commons-collections-3.2.2.jar may be multiply loaded by modules: [/opt/autopsy/autopsy/modules/org-sleuthkit-autopsy-keywordsearch.jar, /opt/autopsy/autopsy/modules/org-sleuthkit-autopsy-core.jar]; see: http://www.netbeans.org/download/dev/javadoc/org-openide-modules/org/openide/modules/doc-files/classpath.html#class-path
WARNING [org.netbeans.core.startup.NbEvents]: The extension /opt/autopsy/autopsy/modules/ext/commons-lang-2.6.jar may be multiply loaded by modules: [/opt/autopsy/autopsy/modules/org-sleuthkit-autopsy-corelibs.jar, /opt/autopsy/autopsy/modules/org-sleuthkit-autopsy-keywordsearch.jar, /opt/autopsy/autopsy/modules/org-sleuthkit-autopsy-core.jar]; see: http://www.netbeans.org/download/dev/javadoc/org-openide-modules/org/openide/modules/doc-files/classpath.html#class-path
WARNING [org.netbeans.core.startup.NbEvents]: The extension /opt/autopsy/autopsy/modules/ext/commons-beanutils-1.9.2.jar may be multiply loaded by modules: [/opt/autopsy/autopsy/modules/org-sleuthkit-autopsy-keywordsearch.jar, /opt/autopsy/autopsy/modules/org-sleuthkit-autopsy-core.jar]; see: http://www.netbeans.org/download/dev/javadoc/org-openide-modules/org/openide/modules/doc-files/classpath.html#class-path
WARNING [org.netbeans.core.startup.NbEvents]: The extension /opt/autopsy/autopsy/modules/ext/sqlite-jdbc-3.25.2.jar may be multiply loaded by modules: [/opt/autopsy/autopsy/modules/org-sleuthkit-autopsy-imagegallery.jar, /opt/autopsy/autopsy/modules/org-sleuthkit-autopsy-core.jar]; see: http://www.netbeans.org/download/dev/javadoc/org-openide-modules/org/openide/modules/doc-files/classpath.html#class-path
WARNING [org.netbeans.core.startup.NbEvents]: The extension /opt/autopsy/autopsy/modules/ext/cdm-4.5.5.jar may be multiply loaded by modules: [/opt/autopsy/autopsy/modules/org-sleuthkit-autopsy-keywordsearch.jar, /opt/autopsy/autopsy/modules/org-sleuthkit-autopsy-Tika.jar]; see: http://www.netbeans.org/download/dev/javadoc/org-openide-modules/org/openide/modules/doc-files/classpath.html#class-path
WARNING [org.netbeans.core.startup.NbEvents]: The extension /opt/autopsy/autopsy/modules/ext/failureaccess-1.0.1.jar may be multiply loaded by modules: [/opt/autopsy/autopsy/modules/org-sleuthkit-autopsy-core.jar, /opt/autopsy/autopsy/modules/org-sleuthkit-autopsy-Tika.jar]; see: http://www.netbeans.org/download/dev/javadoc/org-openide-modules/org/openide/modules/doc-files/classpath.html#class-path
WARNING [org.netbeans.core.startup.NbEvents]: The extension /opt/autopsy/autopsy/modules/ext/boilerpipe-1.1.0.jar may be multiply loaded by modules: [/opt/autopsy/autopsy/modules/org-sleuthkit-autopsy-keywordsearch.jar, /opt/autopsy/autopsy/modules/org-sleuthkit-autopsy-Tika.jar]; see: http://www.netbeans.org/download/dev/javadoc/org-openide-modules/org/openide/modules/doc-files/classpath.html#class-path
WARNING [org.netbeans.core.startup.NbEvents]: The extension /opt/autopsy/autopsy/modules/ext/error_prone_annotations-2.3.2.jar may be multiply loaded by modules: [/opt/autopsy/autopsy/modules/org-sleuthkit-autopsy-core.jar, /opt/autopsy/autopsy/modules/org-sleuthkit-autopsy-Tika.jar]; see: http://www.netbeans.org/download/dev/javadoc/org-openide-modules/org/openide/modules/doc-files/classpath.html#class-path
WARNING [org.netbeans.core.startup.NbEvents]: The extension /opt/autopsy/autopsy/modules/ext/metadata-extractor-2.11.0.jar may be multiply loaded by modules: [/opt/autopsy/autopsy/modules/org-sleuthkit-autopsy-core.jar, /opt/autopsy/autopsy/modules/org-sleuthkit-autopsy-Tika.jar]; see: http://www.netbeans.org/download/dev/javadoc/org-openide-modules/org/openide/modules/doc-files/classpath.html#class-path
WARNING [org.netbeans.core.startup.NbEvents]: The extension /opt/autopsy/autopsy/modules/ext/stax2-api-3.1.4.jar may be multiply loaded by modules: [/opt/autopsy/autopsy/modules/org-sleuthkit-autopsy-keywordsearch.jar, /opt/autopsy/autopsy/modules/org-sleuthkit-autopsy-Tika.jar]; see: http://www.netbeans.org/download/dev/javadoc/org-openide-modules/org/openide/modules/doc-files/classpath.html#class-path
WARNING [org.netbeans.core.startup.NbEvents]: The extension /opt/autopsy/autopsy/modules/ext/xmpcore-5.1.3.jar may be multiply loaded by modules: [/opt/autopsy/autopsy/modules/org-sleuthkit-autopsy-keywordsearch.jar, /opt/autopsy/autopsy/modules/org-sleuthkit-autopsy-core.jar, /opt/autopsy/autopsy/modules/org-sleuthkit-autopsy-Tika.jar]; see: http://www.netbeans.org/download/dev/javadoc/org-openide-modules/org/openide/modules/doc-files/classpath.html#class-path
WARNING [org.netbeans.core.startup.NbEvents]: The extension /opt/autopsy/autopsy/modules/ext/jcommander-1.35.jar may be multiply loaded by modules: [/opt/autopsy/autopsy/modules/org-sleuthkit-autopsy-keywordsearch.jar, /opt/autopsy/autopsy/modules/org-sleuthkit-autopsy-Tika.jar]; see: http://www.netbeans.org/download/dev/javadoc/org-openide-modules/org/openide/modules/doc-files/classpath.html#class-path
WARNING [org.netbeans.core.startup.NbEvents]: The extension /opt/autopsy/autopsy/modules/ext/javax.annotation-api-1.3.2.jar may be multiply loaded by modules: [/opt/autopsy/autopsy/modules/org-sleuthkit-autopsy-core.jar, /opt/autopsy/autopsy/modules/org-sleuthkit-autopsy-Tika.jar]; see: http://www.netbeans.org/download/dev/javadoc/org-openide-modules/org/openide/modules/doc-files/classpath.html#class-path
WARNING [org.netbeans.core.startup.NbEvents]: The extension /opt/autopsy/autopsy/modules/ext/vorbis-java-core-0.8.jar may be multiply loaded by modules: [/opt/autopsy/autopsy/modules/org-sleuthkit-autopsy-keywordsearch.jar, /opt/autopsy/autopsy/modules/org-sleuthkit-autopsy-Tika.jar]; see: http://www.netbeans.org/download/dev/javadoc/org-openide-modules/org/openide/modules/doc-files/classpath.html#class-path
WARNING [org.netbeans.core.startup.NbEvents]: The extension /opt/autopsy/autopsy/modules/ext/java-libpst-0.8.1.jar may be multiply loaded by modules: [/opt/autopsy/autopsy/modules/org-sleuthkit-autopsy-keywordsearch.jar, /opt/autopsy/autopsy/modules/org-sleuthkit-autopsy-Tika.jar]; see: http://www.netbeans.org/download/dev/javadoc/org-openide-modules/org/openide/modules/doc-files/classpath.html#class-path
WARNING [org.netbeans.core.startup.NbEvents]: The extension /opt/autopsy/autopsy/modules/ext/opennlp-tools-1.9.1.jar may be multiply loaded by modules: [/opt/autopsy/autopsy/modules/org-sleuthkit-autopsy-core.jar, /opt/autopsy/autopsy/modules/org-sleuthkit-autopsy-Tika.jar]; see: http://www.netbeans.org/download/dev/javadoc/org-openide-modules/org/openide/modules/doc-files/classpath.html#class-path
WARNING [org.netbeans.core.startup.NbEvents]: The extension /opt/autopsy/autopsy/modules/ext/bzip2-0.9.1.jar may be multiply loaded by modules: [/opt/autopsy/autopsy/modules/org-sleuthkit-autopsy-keywordsearch.jar, /opt/autopsy/autopsy/modules/org-sleuthkit-autopsy-Tika.jar]; see: http://www.netbeans.org/download/dev/javadoc/org-openide-modules/org/openide/modules/doc-files/classpath.html#class-path
WARNING [org.netbeans.core.startup.NbEvents]: The extension /opt/autopsy/autopsy/modules/ext/grib-4.5.5.jar may be multiply loaded by modules: [/opt/autopsy/autopsy/modules/org-sleuthkit-autopsy-keywordsearch.jar, /opt/autopsy/autopsy/modules/org-sleuthkit-autopsy-Tika.jar]; see: http://www.netbeans.org/download/dev/javadoc/org-openide-modules/org/openide/modules/doc-files/classpath.html#class-path
WARNING [org.netbeans.core.startup.NbEvents]: The extension /opt/autopsy/autopsy/modules/ext/httpcore-4.4.12.jar may be multiply loaded by modules: [/opt/autopsy/autopsy/modules/org-sleuthkit-autopsy-keywordsearch.jar, /opt/autopsy/autopsy/modules/org-sleuthkit-autopsy-Tika.jar]; see: http://www.netbeans.org/download/dev/javadoc/org-openide-modules/org/openide/modules/doc-files/classpath.html#class-path
WARNING [org.netbeans.core.startup.NbEvents]: The extension /opt/autopsy/autopsy/modules/ext/httpmime-4.5.10.jar may be multiply loaded by modules: [/opt/autopsy/autopsy/modules/org-sleuthkit-autopsy-keywordsearch.jar, /opt/autopsy/autopsy/modules/org-sleuthkit-autopsy-Tika.jar]; see: http://www.netbeans.org/download/dev/javadoc/org-openide-modules/org/openide/modules/doc-files/classpath.html#class-path
WARNING [org.netbeans.core.startup.NbEvents]: The extension /opt/autopsy/autopsy/modules/ext/httpservices-4.5.5.jar may be multiply loaded by modules: [/opt/autopsy/autopsy/modules/org-sleuthkit-autopsy-keywordsearch.jar, /opt/autopsy/autopsy/modules/org-sleuthkit-autopsy-Tika.jar]; see: http://www.netbeans.org/download/dev/javadoc/org-openide-modules/org/openide/modules/doc-files/classpath.html#class-path
WARNING [org.netbeans.core.startup.NbEvents]: The extension /opt/autopsy/autopsy/modules/ext/joda-time-2.2.jar may be multiply loaded by modules: [/opt/autopsy/autopsy/modules/org-sleuthkit-autopsy-keywordsearch.jar, /opt/autopsy/autopsy/modules/org-sleuthkit-autopsy-Tika.jar]; see: http://www.netbeans.org/download/dev/javadoc/org-openide-modules/org/openide/modules/doc-files/classpath.html#class-path
WARNING [org.netbeans.core.startup.NbEvents]: The extension /opt/autopsy/autopsy/modules/ext/listenablefuture-9999.0-empty-to-avoid-conflict-with-guava.jar may be multiply loaded by modules: [/opt/autopsy/autopsy/modules/org-sleuthkit-autopsy-core.jar, /opt/autopsy/autopsy/modules/org-sleuthkit-autopsy-Tika.jar]; see: http://www.netbeans.org/download/dev/javadoc/org-openide-modules/org/openide/modules/doc-files/classpath.html#class-path
WARNING [org.netbeans.core.startup.NbEvents]: The extension /opt/autopsy/autopsy/modules/ext/commons-io-2.6.jar may be multiply loaded by modules: [/opt/autopsy/autopsy/modules/org-sleuthkit-autopsy-keywordsearch.jar, /opt/autopsy/autopsy/modules/org-sleuthkit-autopsy-Tika.jar]; see: http://www.netbeans.org/download/dev/javadoc/org-openide-modules/org/openide/modules/doc-files/classpath.html#class-path
WARNING [org.netbeans.core.startup.NbEvents]: The extension /opt/autopsy/autopsy/modules/ext/netcdf4-4.5.5.jar may be multiply loaded by modules: [/opt/autopsy/autopsy/modules/org-sleuthkit-autopsy-keywordsearch.jar, /opt/autopsy/autopsy/modules/org-sleuthkit-autopsy-Tika.jar]; see: http://www.netbeans.org/download/dev/javadoc/org-openide-modules/org/openide/modules/doc-files/classpath.html#class-path
WARNING [org.netbeans.core.startup.NbEvents]: The extension /opt/autopsy/autopsy/modules/ext/juniversalchardet-1.0.3.jar may be multiply loaded by modules: [/opt/autopsy/autopsy/modules/org-sleuthkit-autopsy-keywordsearch.jar, /opt/autopsy/autopsy/modules/org-sleuthkit-autopsy-Tika.jar]; see: http://www.netbeans.org/download/dev/javadoc/org-openide-modules/org/openide/modules/doc-files/classpath.html#class-path
WARNING [org.netbeans.core.startup.NbEvents]: The extension /opt/autopsy/autopsy/modules/ext/jsr305-3.0.2.jar may be multiply loaded by modules: [/opt/autopsy/autopsy/modules/org-sleuthkit-autopsy-core.jar, /opt/autopsy/autopsy/modules/org-sleuthkit-autopsy-Tika.jar]; see: http://www.netbeans.org/download/dev/javadoc/org-openide-modules/org/openide/modules/doc-files/classpath.html#class-path
WARNING [org.netbeans.core.startup.NbEvents]: The extension /opt/autopsy/autopsy/modules/ext/jcip-annotations-1.0.jar may be multiply loaded by modules: [/opt/autopsy/autopsy/modules/org-sleuthkit-autopsy-keywordsearch.jar, /opt/autopsy/autopsy/modules/org-sleuthkit-autopsy-Tika.jar]; see: http://www.netbeans.org/download/dev/javadoc/org-openide-modules/org/openide/modules/doc-files/classpath.html#class-path
WARNING [org.netbeans.core.startup.NbEvents]: The extension /opt/autopsy/autopsy/modules/ext/ehcache-core-2.6.2.jar may be multiply loaded by modules: [/opt/autopsy/autopsy/modules/org-sleuthkit-autopsy-keywordsearch.jar, /opt/autopsy/autopsy/modules/org-sleuthkit-autopsy-Tika.jar]; see: http://www.netbeans.org/download/dev/javadoc/org-openide-modules/org/openide/modules/doc-files/classpath.html#class-path
WARNING [org.netbeans.core.startup.NbEvents]: The extension /opt/autopsy/autopsy/modules/ext/httpclient-4.5.10.jar may be multiply loaded by modules: [/opt/autopsy/autopsy/modules/org-sleuthkit-autopsy-keywordsearch.jar, /opt/autopsy/autopsy/modules/org-sleuthkit-autopsy-Tika.jar]; see: http://www.netbeans.org/download/dev/javadoc/org-openide-modules/org/openide/modules/doc-files/classpath.html#class-path
WARNING [org.netbeans.core.startup.NbEvents]: The extension /opt/autopsy/autopsy/modules/ext/vorbis-java-tika-0.8.jar may be multiply loaded by modules: [/opt/autopsy/autopsy/modules/org-sleuthkit-autopsy-keywordsearch.jar, /opt/autopsy/autopsy/modules/org-sleuthkit-autopsy-Tika.jar]; see: http://www.netbeans.org/download/dev/javadoc/org-openide-modules/org/openide/modules/doc-files/classpath.html#class-path
WARNING [org.netbeans.core.startup.NbEvents]: The extension /opt/autopsy/autopsy/modules/ext/commons-codec-1.11.jar may be multiply loaded by modules: [/opt/autopsy/autopsy/modules/org-sleuthkit-autopsy-corelibs.jar, /opt/autopsy/autopsy/modules/org-sleuthkit-autopsy-core.jar]; see: http://www.netbeans.org/download/dev/javadoc/org-openide-modules/org/openide/modules/doc-files/classpath.html#class-path
WARNING [org.netbeans.core.startup.NbEvents]: The extension /opt/autopsy/autopsy/modules/ext/guava-19.0.jar may be multiply loaded by modules: [/opt/autopsy/autopsy/modules/org-sleuthkit-autopsy-corelibs.jar, /opt/autopsy/autopsy/modules/org-sleuthkit-autopsy-thunderbirdparser.jar]; see: http://www.netbeans.org/download/dev/javadoc/org-openide-modules/org/openide/modules/doc-files/classpath.html#class-path
WARNING [org.netbeans.core.startup.NbEvents]: The extension /opt/autopsy/autopsy/modules/ext/commons-lang-2.6.jar may be multiply loaded by modules: [/opt/autopsy/autopsy/modules/org-sleuthkit-autopsy-corelibs.jar, /opt/autopsy/autopsy/modules/org-sleuthkit-autopsy-keywordsearch.jar, /opt/autopsy/autopsy/modules/org-sleuthkit-autopsy-core.jar]; see: http://www.netbeans.org/download/dev/javadoc/org-openide-modules/org/openide/modules/doc-files/classpath.html#class-path
WARNING [org.netbeans.core.startup.NbEvents]: The extension /opt/autopsy/autopsy/modules/ext/poi-4.0.1.jar may be multiply loaded by modules: [/opt/autopsy/autopsy/modules/org-sleuthkit-autopsy-corelibs.jar, /opt/autopsy/autopsy/modules/org-sleuthkit-autopsy-keywordsearch.jar]; see: http://www.netbeans.org/download/dev/javadoc/org-openide-modules/org/openide/modules/doc-files/classpath.html#class-path
WARNING [org.netbeans.core.startup.NbEvents]: The extension /opt/autopsy/autopsy/modules/ext/poi-ooxml-schemas-4.0.1.jar may be multiply loaded by modules: [/opt/autopsy/autopsy/modules/org-sleuthkit-autopsy-corelibs.jar, /opt/autopsy/autopsy/modules/org-sleuthkit-autopsy-keywordsearch.jar]; see: http://www.netbeans.org/download/dev/javadoc/org-openide-modules/org/openide/modules/doc-files/classpath.html#class-path
WARNING [org.netbeans.core.startup.NbEvents]: The extension /opt/autopsy/autopsy/modules/ext/LGoodDatePicker-10.3.1.jar may be multiply loaded by modules: [/opt/autopsy/autopsy/modules/org-sleuthkit-autopsy-corelibs.jar, /opt/autopsy/autopsy/modules/org-sleuthkit-autopsy-experimental.jar]; see: http://www.netbeans.org/download/dev/javadoc/org-openide-modules/org/openide/modules/doc-files/classpath.html#class-path
WARNING [org.netbeans.core.startup.NbEvents]: The extension /opt/autopsy/autopsy/modules/ext/mchange-commons-java-0.2.9.jar may be multiply loaded by modules: [/opt/autopsy/autopsy/modules/org-sleuthkit-autopsy-core.jar, /opt/autopsy/autopsy/modules/org-sleuthkit-autopsy-experimental.jar]; see: http://www.netbeans.org/download/dev/javadoc/org-openide-modules/org/openide/modules/doc-files/classpath.html#class-path
WARNING [org.netbeans.core.startup.NbEvents]: The extension /opt/autopsy/autopsy/modules/ext/c3p0-0.9.5.jar may be multiply loaded by modules: [/opt/autopsy/autopsy/modules/org-sleuthkit-autopsy-core.jar, /opt/autopsy/autopsy/modules/org-sleuthkit-autopsy-experimental.jar]; see: http://www.netbeans.org/download/dev/javadoc/org-openide-modules/org/openide/modules/doc-files/classpath.html#class-path
SEVERE [org.openide.util.Exceptions]
java.lang.reflect.InaccessibleObjectException: Unable to make protected java.util.Enumeration java.lang.ClassLoader.findResources(java.lang.String) throws java.io.IOException accessible: module java.base does not "opens java.lang" to unnamed module @677327b6
SEVERE [org.openide.util.Exceptions]
java.lang.IllegalAccessException: class org.netbeans.Module cannot access a member of class java.lang.ClassLoader (in module java.base) with modifiers "protected"
SEVERE [null]: Last record repeated 24 times in total.
SEVERE [org.openide.util.Exceptions]
java.lang.IllegalAccessException: class org.netbeans.Module cannot access a member of class java.lang.ClassLoader (in module java.base) with modifiers "protected"
SEVERE [null]: Last record repeated again.
SEVERE [org.openide.util.Exceptions]
java.lang.IllegalAccessException: class org.netbeans.Module cannot access a member of class java.lang.ClassLoader (in module java.base) with modifiers "protected"
SEVERE [null]: Last record repeated 5 more times.
SEVERE [org.openide.util.Exceptions]
java.lang.IllegalAccessException: class org.netbeans.Module cannot access a member of class java.lang.ClassLoader (in module java.base) with modifiers "protected"
SEVERE [org.openide.util.Exceptions]
java.lang.IllegalAccessException: class org.netbeans.Module cannot access a member of class java.lang.ClassLoader (in module java.base) with modifiers "protected"
SEVERE [null]: Last record repeated 5 more times.
SEVERE [org.openide.util.Exceptions]
java.lang.IllegalAccessException: class org.netbeans.Module cannot access a member of class java.lang.ClassLoader (in module java.base) with modifiers "protected"
SEVERE [null]: Last record repeated 2 more times.
SEVERE [org.openide.util.Exceptions]
java.lang.IllegalAccessException: class org.netbeans.Module cannot access a member of class java.lang.ClassLoader (in module java.base) with modifiers "protected"
SEVERE [null]: Last record repeated 30 times in total.
SEVERE [org.openide.util.Exceptions]
java.lang.IllegalAccessException: class org.netbeans.Module cannot access a member of class java.lang.ClassLoader (in module java.base) with modifiers "protected"
SEVERE [null]: Last record repeated 2 more times.
SEVERE [org.openide.util.Exceptions]
java.lang.IllegalAccessException: class org.netbeans.Module cannot access a member of class java.lang.ClassLoader (in module java.base) with modifiers "protected"
SEVERE [null]: Last record repeated 12 times in total.
SEVERE [org.openide.util.Exceptions]
java.lang.IllegalAccessException: class org.netbeans.Module cannot access a member of class java.lang.ClassLoader (in module java.base) with modifiers "protected"
SEVERE [null]: Last record repeated 2 more times.
SEVERE [org.openide.util.Exceptions]
java.lang.IllegalAccessException: class org.netbeans.Module cannot access a member of class java.lang.ClassLoader (in module java.base) with modifiers "protected"
SEVERE [null]: Last record repeated 12 times in total.
SEVERE [org.openide.util.Exceptions]
java.lang.IllegalAccessException: class org.netbeans.Module cannot access a member of class java.lang.ClassLoader (in module java.base) with modifiers "protected"
SEVERE [null]: Last record repeated 4 more times.
SEVERE [org.openide.util.Exceptions]
java.lang.IllegalAccessException: class org.netbeans.Module cannot access a member of class java.lang.ClassLoader (in module java.base) with modifiers "protected"
SEVERE [null]: Last record repeated 5 more times.
SEVERE [org.openide.util.Exceptions]
java.lang.IllegalAccessException: class org.netbeans.Module cannot access a member of class java.lang.ClassLoader (in module java.base) with modifiers "protected"
SEVERE [null]: Last record repeated 18 times in total.
SEVERE [org.openide.util.Exceptions]
java.lang.IllegalAccessException: class org.netbeans.Module cannot access a member of class java.lang.ClassLoader (in module java.base) with modifiers "protected"
SEVERE [null]: Last record repeated 5 more times.
SEVERE [org.openide.util.Exceptions]
java.lang.IllegalAccessException: class org.netbeans.Module cannot access a member of class java.lang.ClassLoader (in module java.base) with modifiers "protected"
SEVERE [null]: Last record repeated 6 more times.
WARNING [org.openide.loaders.DataLoader]
java.lang.NullPointerException: Cannot invoke "org.openide.filesystems.FileObject.isValid()" because "fo" is null
SEVERE [org.openide.util.Exceptions]
java.lang.NullPointerException: Cannot invoke "org.openide.filesystems.FileObject.isValid()" because "fo" is null
Caused: java.io.IOException
WARNING [org.netbeans.modules.autoupdate.ui.actions.AutoupdateSettings]: The property "netbeans.default_userdir_root" was not set!
INFO [org.netbeans.core.startup.NbEvents]: Turning on modules:
INFO [org.netbeans.ui.metrics.laf]: USG_LOOK_AND_FEEL
WARNING [org.netbeans.core.windows.PersistenceHandler]
msg
Caused: java.io.FileNotFoundException: [WinSys] Missing Window Manager configuration file
ALL [null]: Cannot load window system persistent data, user directory content is broken. Resetting to default layout...

---

# gemini response

El problema está directamente en la versión de Java que estás utilizando para ejecutar Autopsy. Los logs revelan exactamente lo que está pasando:

1. **`module java.base does not "opens java.net" to unnamed module`**: A partir de Java 16 (y más estrictamente en Java 17), Java bloquea el acceso mediante *reflection* a sus APIs internas por defecto. La plataforma NetBeans (sobre la que corre Autopsy) necesita acceder a ellas y el JDK se lo está denegando.
2. **`Setting a Security Manager is not supported`**: Esta es la confirmación definitiva. El Security Manager fue deprecado para su eliminación en Java 17, y a partir de Java 18 lanzar esta función tira exactamente esta excepción (`UnsupportedOperationException`). 

Básicamente, estás intentando correr Autopsy con una versión de Java demasiado nueva (probablemente Java 18, 21 o superior), y la arquitectura modular del programa se rompe por las nuevas políticas de seguridad de la JVM.

### La Solución: Forzar la versión correcta de Java

Autopsy suele estar diseñado para compilar y correr con **Java 11** o **Java 17** (dependiendo de si estás en la versión 4.19 o en la familia de las 4.20+). Necesitas instalar la versión correspondiente y apuntar la configuración de Autopsy hacia ella sin tocar la versión global de tu sistema (para no romper otras cosas en tu entorno Sid/Manjaro).

**Paso 1: Localizar o instalar el JDK correcto**
Lo ideal para Autopsy en Linux es usar un JDK que incluya JavaFX (como BellSoft Liberica JDK Full). Si ya tienes OpenJDK 11 o 17 instalado (junto con OpenJFX), busca dónde está ubicado. Usualmente en Debian/Sid o Arch está en `/usr/lib/jvm/`.

Puedes ver las versiones instaladas con:
```bash
ls -l /usr/lib/jvm/
```

**Paso 2: Editar el archivo de configuración de Autopsy**
En lugar de depender del Java por defecto del sistema, vamos a hardcodear la ruta del JDK directamente en el archivo de configuración de Autopsy. 

Sabiendo que tienes Autopsy en `/opt/`, abre el archivo de configuración:

```bash
sudo geany /opt/autopsy/autopsy/etc/autopsy.conf
```

**Paso 3: Modificar la variable `jdkhome`**
Dentro de ese archivo, busca una línea que dice `#jdkhome="/path/to/jdk"`.
Descoméntala (quítale el `#`) y pon la ruta exacta a tu Java 11 o 17. Debería quedar algo así:

```text
jdkhome="/usr/lib/jvm/java-11-openjdk-amd64"
```
*(Asegúrate de poner el nombre exacto de la carpeta que encontraste en el Paso 1).*

Guarda el archivo, usa tu alias de `tput clear` para limpiar el desastre de la terminal, y vuelve a lanzar Autopsy. Al forzarlo a usar la JVM más antigua, los errores de encapsulación y del Security Manager deberían desaparecer, permitiendo que la GUI de NetBeans levante correctamente.

---

# you asked

> ls -l /usr/lib/jvm/
total 8
lrwxrwxrwx 1 root root 15 abr  8 07:34 default -> java-26-openjdk
lrwxrwxrwx 1 root root 15 abr  8 07:34 default-runtime -> java-26-openjdk
drwxr-xr-x 1 root root 82 abr  8 08:23 java-11-openjdk
drwxr-xr-x 1 root root 82 abr  8 07:34 java-26-openjdk

---

# gemini response

Confirmado: el culpable es ese enlace simbólico que apunta a **Java 26**. Autopsy no tiene ninguna posibilidad de correr en una versión tan experimental y estricta de la JVM; de hecho, Java 26 es demasiado moderna incluso para la mayoría de las herramientas forenses actuales.

Tienes instalada la versión **java-11-openjdk**, que es exactamente la que Autopsy (especialmente si es la versión 4.19 o similar) necesita para funcionar de manera estable.

### Pasos para corregir el arranque

Sigue estos pasos para forzar a Autopsy a usar el entorno compatible:

1.  **Edita la configuración:**
    Como sueles usar Geany, abre el archivo con privilegios de superusuario:
    ```bash
    sudo geany /opt/autopsy/autopsy/etc/autopsy.conf
    ```

2.  **Define el JDK:**
    Busca la línea que comienza con `jdkhome`. Probablemente esté comentada con un `#`. Cámbiala para que quede exactamente así:
    ```text
    jdkhome="/usr/lib/jvm/java-11-openjdk"
    ```

3.  **Limpia el rastro del error anterior:**
    Dado que intentaste arrancar con Java 26, el directorio de usuario puede tener archivos de caché corruptos o incompletos (el error `Missing Window Manager configuration file` que viste antes). Te recomiendo resetearlo:
    ```bash
    rm -rf ~/.autopsy/dev/var
    ```

4.  **Ejecuta nuevamente:**
    Lanza el binario de Autopsy. Ahora debería ignorar el Java 26 del sistema y cargar correctamente todos los módulos de la plataforma NetBeans usando la versión 11.

---

### Un detalle importante sobre JavaFX
Si después de hacer esto Autopsy arranca pero ves que la interfaz no muestra los gráficos o se cierra al abrir un caso, es porque a la instalación de **OpenJDK 11** le faltan los módulos de **OpenJFX**. 

En sistemas basados en Arch/Manjaro (como el que parece que estás usando), puedes verificar si tienes el paquete `java11-openjfx` instalado. Si no, lo necesitarás para que la GUI funcione al 100%.

---

# you asked

Funciona

---

# gemini response

¡Excelente! El `jdkhome` nunca falla para domar a NetBeans cuando el sistema tiene versiones de Java demasiado experimentales.

Ya que lograste que levantara, un par de consejos rápidos para tu entorno **Frankeinux / Debian Sid**:

* **Persistencia de la configuración:** Si alguna vez actualizas Autopsy a una versión nueva en `/opt`, recuerda que el archivo `autopsy.conf` se sobrescribirá. Te conviene tener un backup de esa línea o un pequeño script de post-instalación.
* **Case Management:** Al estar en Linux, asegúrate de que el directorio donde creas los "Cases" tenga permisos de escritura completos para tu usuario `eze`, ya que a veces Autopsy se pone caprichoso con los permisos si los discos están montados con configuraciones restrictivas.
* **Desempeño:** Como tienes un Phenom II X4, si notas que el "Ingest" (el indexado de archivos) se vuelve muy pesado, puedes limitar el número de hilos en `Tools -> Options -> Autopsy -> Ingest`.

Cualquier otro error de librerías o si te falta algún `.so` de *The Sleuth Kit*, avisame y lo resolvemos con un `ldd` rápido.