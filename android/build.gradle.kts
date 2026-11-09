allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    val proj = this
    if (proj.name != "app") {
        proj.plugins.withId("com.android.library") {
            val android = proj.extensions.findByName("android")
            if (android != null) {
                try {
                    val setNamespace = android.javaClass.getMethod("setNamespace", String::class.java)
                    val ns = if (proj.name == "on_audio_query_android") {
                        "com.lucasjosino.on_audio_query"
                    } else {
                        "com.example.${proj.name.replace('-', '_')}"
                    }
                    setNamespace.invoke(android, ns)
                } catch (_: Exception) {}

                try {
                    val getCompileOptions = android.javaClass.getMethod("getCompileOptions")
                    val compileOptions = getCompileOptions.invoke(android)
                    val setSource = compileOptions.javaClass.getMethod("setSourceCompatibility", Any::class.java)
                    val setTarget = compileOptions.javaClass.getMethod("setTargetCompatibility", Any::class.java)
                    setSource.invoke(compileOptions, JavaVersion.VERSION_17)
                    setTarget.invoke(compileOptions, JavaVersion.VERSION_17)
                } catch (_: Exception) {}
            }
        }
    }

    proj.tasks.withType<JavaCompile>().configureEach {
        sourceCompatibility = "17"
        targetCompatibility = "17"
    }

    proj.tasks.matching { it.name.contains("Kotlin") }.configureEach {
        try {
            val getCompilerOptions = this.javaClass.getMethod("getCompilerOptions")
            val compOpts = getCompilerOptions.invoke(this)
            val getJvmTarget = compOpts.javaClass.getMethod("getJvmTarget")
            val jvmTargetProp = getJvmTarget.invoke(compOpts)
            val setMethod = jvmTargetProp.javaClass.getMethod("set", Any::class.java)
            val jvmTargetEnum = Class.forName("org.jetbrains.kotlin.gradle.dsl.JvmTarget").getField("JVM_17").get(null)
            setMethod.invoke(jvmTargetProp, jvmTargetEnum)
        } catch (_: Exception) {}

        try {
            val getKotlinOptions = this.javaClass.getMethod("getKotlinOptions")
            val kotlinOpts = getKotlinOptions.invoke(this)
            val setJvmTarget = kotlinOpts.javaClass.getMethod("setJvmTarget", String::class.java)
            setJvmTarget.invoke(kotlinOpts, "17")
        } catch (_: Exception) {}
    }
}

subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
