package com.madrapps.jacoco

import org.junit.jupiter.api.Assertions
import org.junit.jupiter.api.Test

class MathTest {

    @Test
    fun testAdd() {
        val math = Arithmetic()
        val actual = math.add(3, 4)
        Assertions.assertEquals(7, actual)
    }

    @Test
    fun testSubtract() {
        val math = Arithmetic()
        val actual = math.subtract(8, 4)
        Assertions.assertEquals(4, actual)
    }

    @Test
    fun testMultiply() {
        val math = Arithmetic()
        val actual = math.multiply(8, 2)
        Assertions.assertEquals(16, actual)
    }

    @Test
    fun testDivide() {
        val math = Arithmetic()
        val actual = math.divide(8, 2)
        Assertions.assertEquals(4, actual)
    }

}