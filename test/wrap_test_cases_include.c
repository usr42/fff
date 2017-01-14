int own_wrapvoidfunc0_called = 0;

void own_wrapvoidfunc0()
{
    own_wrapvoidfunc0_called++;
}

TEST_F(FFFWrapTestSuite, custom_fake_is_set_to_real_function)
{
    ASSERT_EQ(__real_wrapvoidfunc0, __wrap_wrapvoidfunc0_fake.custom_fake);
}

TEST_F(FFFWrapTestSuite, by_default_real_function_is_called)
{
    wrapvoidfunc0();

    ASSERT_EQ(1, real_wrapvoidfunc0_called);
}

TEST_F(FFFWrapTestSuite, real_function_is_not_called_if_custom_fake_is_set_to_null)
{
    __wrap_wrapvoidfunc0_fake.custom_fake = NULL;

    wrapvoidfunc0();

    ASSERT_EQ(0, real_wrapvoidfunc0_called);
}

TEST_F(FFFWrapTestSuite, custom_fake_is_real_function_after_RESET_WRAP_FAKE_called)
{
    __wrap_wrapvoidfunc0_fake.custom_fake = NULL;

    RESET_WRAP_FAKE(wrapvoidfunc0);

    ASSERT_EQ(__real_wrapvoidfunc0, __wrap_wrapvoidfunc0_fake.custom_fake);
}

TEST_F(FFFWrapTestSuite, when_wrap_func_called_once_then_callcount_is_one)
{
    wrapvoidfunc0();

    ASSERT_EQ(1, __wrap_wrapvoidfunc0_fake.call_count);
}

TEST_F(FFFWrapTestSuite, when_wrap_func_called_once_and_reset_then_callcount_is_zero)
{
    wrapvoidfunc0();
    RESET_WRAP_FAKE(wrapvoidfunc0);

    ASSERT_EQ(0, __wrap_wrapvoidfunc0_fake.call_count);
}

TEST_F(FFFWrapTestSuite, when_custom_fake_changed_own_custom_fake_called_not_real)
{
    __wrap_wrapvoidfunc0_fake.custom_fake = own_wrapvoidfunc0;

    wrapvoidfunc0();

    ASSERT_EQ(0, real_wrapvoidfunc0_called);
    ASSERT_EQ(1, own_wrapvoidfunc0_called);
}

TEST_F(FFFWrapTestSuite, when_custom_fake_set_to_NULL_no_function_called_but_counter_incremented)
{
    __wrap_wrapvoidfunc0_fake.custom_fake = NULL;

    wrapvoidfunc0();

    ASSERT_EQ(0, real_wrapvoidfunc0_called);
    ASSERT_EQ(0, own_wrapvoidfunc0_called);
    ASSERT_EQ(1, __wrap_wrapvoidfunc0_fake.call_count);
}
