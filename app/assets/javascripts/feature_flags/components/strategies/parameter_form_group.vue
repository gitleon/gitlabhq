<script>
import { uniqueId } from 'lodash';
import { GlFormGroup } from '@gitlab/ui';

export default {
  components: {
    GlFormGroup,
  },
  props: {
    inputId: {
      required: false,
      type: String,
      default: () => uniqueId('feature_flag_strategies_'),
    },
  },
};
</script>
<template>
  <gl-form-group :label-for="inputId" v-bind="$attrs">
    <slot v-bind="{ inputId }"></slot>
  </gl-form-group>
</template>
