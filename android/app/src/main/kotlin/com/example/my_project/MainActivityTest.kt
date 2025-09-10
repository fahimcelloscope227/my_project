package com.example.my_project

import androidx.test.platform.app.InstrumentationRegistry
import org.junit.Test
import org.junit.runner.RunWith
import org.junit.runners.Parameterized
import pl.leancode.patrol.PatrolJUnitRunner

@RunWith(Parameterized::class)
class MainActivityTest(private val dartTestName: String) {

    companion object {
        @JvmStatic
        @Parameterized.Parameters(name = "{0}")
        fun testCases(): Array<String> {
            val instrumentation =
                InstrumentationRegistry.getInstrumentation() as PatrolJUnitRunner
            instrumentation.setUp(MainActivity::class.java)
            instrumentation.waitForPatrolAppService()
            return instrumentation.listDartTests() as Array<String>
        }
    }

    @Test
    fun runDartTest() {
        val instrumentation =
            InstrumentationRegistry.getInstrumentation() as PatrolJUnitRunner
        instrumentation.runDartTest(dartTestName)
    }
}
