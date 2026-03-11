package com.madrapps.jacoco;

import org.junit.jupiter.api.Assertions;
import org.junit.jupiter.api.Test;

public class UtilsTest {

    @Test
    public void testAdd() {
        final Utils utils = new Utils();
        int actual = utils.add(2, 3);
        Assertions.assertEquals(5, actual);
    }

    @Test
    public void testSubtract() {
        final Utils utils = new Utils();
        int actual = utils.subtract(8, 3);
        Assertions.assertEquals(5, actual);
    }

    @Test
    public void testSquare() {
        final Utils utils = new Utils();
        int actual = utils.square(3);
        Assertions.assertEquals(9, actual);
    }
}

