package com.madrapps.jacoco.operation;

import org.junit.jupiter.api.Assertions;
import org.junit.jupiter.api.Test;

public class StringOpTest {

    @Test
    public void testEndsWith() {
        final StringOp stringOp = new StringOp();
        final boolean actual = stringOp.endsWith("something", "thing");
        Assertions.assertTrue(actual);
    }

    @Test
    public void testStartsWith() {
        final StringOp stringOp = new StringOp();
        final boolean actual = stringOp.startsWith("something", "thing");
        Assertions.assertFalse(actual);
    }
}
