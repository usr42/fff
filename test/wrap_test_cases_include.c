int own_wrapvoidfunc0_called = 0;

void own_wrapvoidfunc0()
{
    own_wrapvoidfunc0_called++;
}

TEST_F(FFFWrapTestSuite, custom_fake_is_set_to_real_function)
{
    ASSERT_EQ(__real_wrapvoidfunc0, wrapvoidfunc0_fake->custom_fake);
}

TEST_F(FFFWrapTestSuite, by_default_real_function_is_called)
{
    wrapvoidfunc0();

    ASSERT_EQ(1, real_wrapvoidfunc0_called);
}

TEST_F(FFFWrapTestSuite, real_function_is_not_called_if_custom_fake_is_set_to_null)
{
    wrapvoidfunc0_fake->custom_fake = NULL;

    wrapvoidfunc0();

    ASSERT_EQ(0, real_wrapvoidfunc0_called);
}

TEST_F(FFFWrapTestSuite, custom_fake_is_real_function_after_RESET_WRAP_FAKE_called)
{
    wrapvoidfunc0_fake->custom_fake = NULL;

    RESET_WRAP_FAKE(wrapvoidfunc0);

    ASSERT_EQ(__real_wrapvoidfunc0, wrapvoidfunc0_fake->custom_fake);
}

TEST_F(FFFWrapTestSuite, when_wrap_func_called_once_then_callcount_is_one)
{
    wrapvoidfunc0();

    ASSERT_EQ(1, wrapvoidfunc0_fake->call_count);
}

TEST_F(FFFWrapTestSuite, when_wrap_func_called_once_and_reset_then_callcount_is_zero)
{
    wrapvoidfunc0();
    RESET_WRAP_FAKE(wrapvoidfunc0);

    ASSERT_EQ(0, wrapvoidfunc0_fake->call_count);
}

TEST_F(FFFWrapTestSuite, when_custom_fake_changed_own_custom_fake_called_not_real)
{
    wrapvoidfunc0_fake->custom_fake = own_wrapvoidfunc0;

    wrapvoidfunc0();

    ASSERT_EQ(0, real_wrapvoidfunc0_called);
    ASSERT_EQ(1, own_wrapvoidfunc0_called);
}

TEST_F(FFFWrapTestSuite, when_custom_fake_set_to_NULL_no_function_called_but_counter_incremented)
{
    wrapvoidfunc0_fake->custom_fake = NULL;

    wrapvoidfunc0();

    ASSERT_EQ(0, real_wrapvoidfunc0_called);
    ASSERT_EQ(0, own_wrapvoidfunc0_called);
    ASSERT_EQ(1, wrapvoidfunc0_fake->call_count);
}

TEST_F(FFFWrapTestSuite, wrap_can_capture_upto_20_arguments_correctly)
{
    wrapvoidfunc20(0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19);
    ASSERT_EQ(0, wrapvoidfunc20_fake->arg0_val);
    ASSERT_EQ(1, wrapvoidfunc20_fake->arg1_val);
    ASSERT_EQ(2, wrapvoidfunc20_fake->arg2_val);
    ASSERT_EQ(3, wrapvoidfunc20_fake->arg3_val);
    ASSERT_EQ(4, wrapvoidfunc20_fake->arg4_val);
    ASSERT_EQ(5, wrapvoidfunc20_fake->arg5_val);
    ASSERT_EQ(6, wrapvoidfunc20_fake->arg6_val);
    ASSERT_EQ(7, wrapvoidfunc20_fake->arg7_val);
    ASSERT_EQ(8, wrapvoidfunc20_fake->arg8_val);
    ASSERT_EQ(9, wrapvoidfunc20_fake->arg9_val);
    ASSERT_EQ(10, wrapvoidfunc20_fake->arg10_val);
    ASSERT_EQ(11, wrapvoidfunc20_fake->arg11_val);
    ASSERT_EQ(12, wrapvoidfunc20_fake->arg12_val);
    ASSERT_EQ(13, wrapvoidfunc20_fake->arg13_val);
    ASSERT_EQ(14, wrapvoidfunc20_fake->arg14_val);
    ASSERT_EQ(15, wrapvoidfunc20_fake->arg15_val);
    ASSERT_EQ(16, wrapvoidfunc20_fake->arg16_val);
    ASSERT_EQ(17, wrapvoidfunc20_fake->arg17_val);
    ASSERT_EQ(18, wrapvoidfunc20_fake->arg18_val);
    ASSERT_EQ(19, wrapvoidfunc20_fake->arg19_val);
}

TEST_F(FFFWrapTestSuite, wrap_can_capture_upto_20_arguments_in_value_funct_correctly)
{
    int ret = wrapvaluefunc20(0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19);
    ASSERT_EQ(0, wrapvaluefunc20_fake->arg0_val);
    ASSERT_EQ(1, wrapvaluefunc20_fake->arg1_val);
    ASSERT_EQ(2, wrapvaluefunc20_fake->arg2_val);
    ASSERT_EQ(3, wrapvaluefunc20_fake->arg3_val);
    ASSERT_EQ(4, wrapvaluefunc20_fake->arg4_val);
    ASSERT_EQ(5, wrapvaluefunc20_fake->arg5_val);
    ASSERT_EQ(6, wrapvaluefunc20_fake->arg6_val);
    ASSERT_EQ(7, wrapvaluefunc20_fake->arg7_val);
    ASSERT_EQ(8, wrapvaluefunc20_fake->arg8_val);
    ASSERT_EQ(9, wrapvaluefunc20_fake->arg9_val);
    ASSERT_EQ(10, wrapvaluefunc20_fake->arg10_val);
    ASSERT_EQ(11, wrapvaluefunc20_fake->arg11_val);
    ASSERT_EQ(12, wrapvaluefunc20_fake->arg12_val);
    ASSERT_EQ(13, wrapvaluefunc20_fake->arg13_val);
    ASSERT_EQ(14, wrapvaluefunc20_fake->arg14_val);
    ASSERT_EQ(15, wrapvaluefunc20_fake->arg15_val);
    ASSERT_EQ(16, wrapvaluefunc20_fake->arg16_val);
    ASSERT_EQ(17, wrapvaluefunc20_fake->arg17_val);
    ASSERT_EQ(18, wrapvaluefunc20_fake->arg18_val);
    ASSERT_EQ(19, wrapvaluefunc20_fake->arg19_val);

    ASSERT_EQ(190, ret);
}

TEST_F(FFFWrapTestSuite, value_function_without_parameters_works)
{
    int ret = wrapvalue0();

    ASSERT_EQ(42, ret);
}

TEST_F(FFFWrapTestSuite, direct_access_to__wrap_struct_is_possible)
{
    wrapvoidfunc0();

    ASSERT_EQ(1, wrapvoidfunc0_fake->call_count);
    ASSERT_EQ(1, __wrap_wrapvoidfunc0_fake.call_count);
}
