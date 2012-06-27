require 'dl/import'

class String
  def blob?
    @blob || false
  end

  def blob=(state)
    raise 'state must be true or false' unless state.is_a?(TrueClass) || state.is_a?(FalseClass)
    @blob = state
  end

  def blob!
    @blob = true
  end
end

module DL
  if const_defined?(:Importable)
    Importer = Importable
  end
end

module CoreFoundation
  OLD_DL = DL.const_defined?(:Importable)
  extend DL::Importer
  
  dlload '/System/Library/Frameworks/CoreFoundation.framework/CoreFoundation'
  
  [
    ['Boolean', 'unsigned char'],
    ['CFAbsoluteTime', 'double'],
    ['CFAbsoluteTime', 'double'],
    ['CFAllocatorRef', 'void *'],
    ['CFAllocatorRef', 'void *'],
    ['CFArrayApplierFunction', 'void *'],
    ['CFArrayCallBacks', 'void *'],
    ['CFArrayRef', 'void *'],
    ['CFBooleanRef', 'void *'],
    ['CFDataRef', 'void *'],
    ['CFDateRef', 'void *'],
    ['CFDictionaryKeyCallBacks', 'void *'],
    ['CFDictionaryRef', 'void *'],
    ['CFIndex', 'unsigned long'],
    ['CFMutableArrayRef', 'void *'],
    ['CFMutableDictionaryRef', 'void *'],
    ['CFNumberRef', 'void *'],
    ['CFNumberType', 'unsigned char'],
    ['CFNumberType', 'unsigned int'],
    ['CFOptionFlags', 'unsigned int'],
    ['CFPropertyListFormat', 'unsigned long'],
    ['CFPropertyListRef', 'void *'],
    ['CFPropertyListRef', 'void *'],
    ['CFRange', 'void *'],
    ['CFReadStreamRef', 'void *'],
    ['CFStringEncoding', 'unsigned int'],
    ['CFStringRef', 'void *'],
    ['CFTypeID', 'unsigned long'],
    ['CFTypeRef', 'void *'],
    ['CFWriteStreamRef', 'void *'],
    ['UInt8', 'unsigned char'],
  ].each do |alias_type, original_type|
    typealias(alias_type, original_type)
  end

  [
    'char * CFStringGetCStringPtr(CFStringRef, CFStringEncoding)',
    'Boolean CFStringGetCString(CFStringRef, char *, CFIndex, CFStringEncoding)',
    'CFIndex CFStringGetLength(CFStringRef)',
    'CFReadStreamRef CFReadStreamCreateWithBytesNoCopy(CFAllocatorRef, UInt8 *, CFIndex, CFAllocatorRef)',
    'Boolean CFReadStreamOpen(CFReadStreamRef)',
    'void CFReadStreamClose(CFReadStreamRef)',
    'CFPropertyListRef CFPropertyListCreateFromStream (CFAllocatorRef, CFReadStreamRef, CFIndex, CFOptionFlags, CFPropertyListFormat *, CFStringRef *)',
    'void CFRelease(CFTypeRef)',
    'CFDataRef CFDataCreateWithBytesNoCopy(CFAllocatorRef, UInt8 *, CFIndex, CFAllocatorRef)',
    'CFPropertyListRef CFPropertyListCreateFromXMLData(CFAllocatorRef, CFDataRef, CFOptionFlags, CFStringRef *)',
    'CFTypeID CFGetTypeID(CFTypeRef)',
    'CFTypeID CFStringGetTypeID(void)',
    'CFTypeID CFDictionaryGetTypeID(void)',
    'CFTypeID CFArrayGetTypeID(void)',
    'CFTypeID CFNumberGetTypeID(void)',
    'CFTypeID CFBooleanGetTypeID(void)',
    'CFTypeID CFDataGetTypeID(void)',
    'CFIndex CFStringGetLength(CFStringRef)',
    'CFIndex CFStringGetBytes(CFStringRef, unsigned long, unsigned long, CFStringEncoding, UInt8, Boolean, UInt8 *, CFIndex, CFIndex *)',
    'CFIndex CFArrayGetCount(CFArrayRef)',
    'void CFArrayApplyFunction(CFArrayRef, CFRange, CFArrayApplierFunction, void *)',
    'Boolean CFNumberGetValue(CFNumberRef, CFNumberType, void *)',
    'Boolean CFBooleanGetValue(CFBooleanRef)',
    'UInt8 * CFDataGetBytePtr(CFDataRef)',
    'CFIndex CFDataGetLength(CFDataRef)',
    'CFAbsoluteTime CFDateGetAbsoluteTime(CFDateRef)',
    'CFWriteStreamRef CFWriteStreamCreateWithAllocatedBuffers(CFAllocatorRef, CFAllocatorRef)',
    'Boolean CFWriteStreamOpen(CFWriteStreamRef)',
    'void CFWriteStreamClose(CFWriteStreamRef)',
    'CFIndex CFPropertyListWriteToStream(CFPropertyListRef, CFWriteStreamRef, CFPropertyListFormat, CFStringRef *)',
    'CFTypeRef CFWriteStreamCopyProperty(CFWriteStreamRef, CFStringRef)',
    'CFDataRef CFDataCreate(CFAllocatorRef, UInt8 *, CFIndex)',
    'CFStringRef CFStringCreateWithBytes(CFAllocatorRef, UInt8 *, CFIndex, CFStringEncoding, Boolean)',
    'void CFDictionaryAddValue(CFMutableDictionaryRef, void *, void *)',
    'CFMutableDictionaryRef CFDictionaryCreateMutable(CFAllocatorRef, CFIndex, CFDictionaryKeyCallBacks *, CFDictionaryValueCallBacks *)',
    'CFMutableArrayRef CFArrayCreateMutable(CFAllocatorRef, CFIndex, CFArrayCallBacks *)',
    'void CFArrayAppendValue(CFMutableArrayRef, void *)',
    'CFNumberRef CFNumberCreate(CFAllocatorRef, CFNumberType, void *)',
    'CFPropertyListRef CFPropertyListCreateFromXMLData(CFAllocatorRef, CFDataRef, CFOptionFlags, CFStringRef *)',
    'void CFDictionaryApplyFunction(CFDictionaryRef, void *, void *)',
    'void CFShowStr(void *)',
    'void CFShow(void *)',
    'Boolean CFNumberIsFloatType(CFNumberRef)',
    'Boolean CFNumberGetValue(CFNumberRef, CFNumberType, void *)',
    'void CFArrayApplyFunction(CFArrayRef, unsigned long, unsigned long, void *, void *)',
    'CFIndex CFArrayGetCount(CFArrayRef)',
    'CFTypeID CFBooleanGetTypeID(void)',
    'CFTypeID CFDataGetTypeID(void)',
    'UInt8 *CFDataGetBytePtr(CFDataRef)',
    'CFIndex CFDataGetLength(CFDataRef)',
    'CFTypeID CFDateGetTypeID(void)',
    'CFAbsoluteTime CFDateGetAbsoluteTime(CFDateRef)',
    'CFDateRef CFDateCreate(CFAllocatorRef, CFAbsoluteTime)',
  ].each do |signature|
    extern(OLD_DL ? signature.gsub(/\(void\)/, '()') : signature)
  end
  
  if OLD_DL
    @SYM.each do |mname, sigs|
      if mname =~ /^cF/
        new_mname = mname[0, 1].upcase + mname[1..-1]
        alias :"#{new_mname}" :"#{mname}"
        module_function new_mname.to_sym
      end
    end
    
    DL::Importable.module_eval do
      alias :import_symbol :symbol
    end
  else
    CFDictionaryApplierFunction = bind('void *CFDictionaryApplierFunction(void *, void *, void *)', :temp)
    CFArrayApplierFunction = bind('void *CFArrayApplierFunction(void *, void *)', :temp)
  end
end

module OSX
  module PropertyList
    # Loads a property list from the file at +filepath+ using OSX::PropertyList.load.
    def self.load_file(filepath, format = false)
      File.open(filepath, "r") do |f|
        OSX::PropertyList.load(f, format)
      end
    end
    # Writes the property list representation of +obj+ to the file at +filepath+ using OSX::PropertyList.dump.
    def self.dump_file(filepath, obj, format = :xml1)
      File.open(filepath, "w") do |f|
        OSX::PropertyList.dump(f, obj, format)
      end
    end

    def self.dump(io, obj, format = :xml1)
      raise 'io must be IO object' unless io.respond_to?(:write)
      _format = case format
      when :openstep; _format = 1 # kCFPropertyListOpenStepFormat
      when :xml1; _format = 100 # kCFPropertyListXMLFormat_v1_0
      when :binary1; _format = 200 # kCFPropertyListBinaryFormat_v1_0;
      else; raise 'format must be one of :openstep, :xml1, or :binary1'
      end
      plist = convert_object(obj)
      data = convert_plist_to_string(plist, _format)
      data ? io.write(data) : nil
    end

    def self.load(io_or_str, ret_format = false)
      plist = nil
      error = ' ' * 8
      format = ' ' * 2

      cf_allocator_default = nil
      cf_allocator_null = CoreFoundation.import_symbol('kCFAllocatorNull').ptr
      cf_property_list_immutable = 0

      buffer = io_or_str.respond_to?(:read) ? io_or_str.read : io_or_str.to_s
      buffer_size = buffer.bytesize rescue buffer.size
      if ret_format
        if buffer_size < 6
          buffer += "\n" * (6 - buffer_size)
          buffer_size = 6
        end
        if ''.respond_to?(:to_ptr)
          error = error.to_ptr
          format = format.to_ptr
          buffer = buffer.to_ptr
        end
        read_stream = CoreFoundation.CFReadStreamCreateWithBytesNoCopy(cf_allocator_default, buffer, buffer_size, cf_allocator_null)
        CoreFoundation.CFReadStreamOpen(read_stream)
        plist = CoreFoundation.CFPropertyListCreateFromStream(cf_allocator_default, read_stream, 0, cf_property_list_immutable, format, error)
        CoreFoundation.CFReadStreamClose(read_stream)
        CoreFoundation.CFRelease(read_stream)
      else
        if ''.respond_to?(:to_ptr)
          error = error.to_ptr
          format = format.to_ptr
        end
        data = CoreFoundation.CFDataCreateWithBytesNoCopy(cf_allocator_default, buffer, buffer_size, cf_allocator_null)
        plist = CoreFoundation.CFPropertyListCreateFromXMLData(cf_allocator_default, data, cf_property_list_immutable, error)
        CoreFoundation.CFRelease(data);
      end
      if plist.nil? || plist.null?
        error_msg = DL::CPtr.new(error.unpack('Q').first) rescue DL::PtrData.new(error.to_s(8).unpack('Q').first)
        buffer_len = CoreFoundation.CFStringGetLength(error_msg) + 1
        buffer = ' ' * buffer_len
        CoreFoundation.CFStringGetCString(error_msg, buffer, buffer_len, 0x8000100)
        raise PropertyListError.new(buffer)
      end
      nil
      obj = convert_property_list_ref(plist)
      CoreFoundation.CFRelease(plist)
      if ret_format
        format = format.to_s(2) if ''.respond_to?(:to_ptr)
        case format.unpack('C').first
        when 1
          [obj, :openstep]
        when 100
          [obj, :xml1]
        when 200
          [obj, :binary1]
        else
          [obj, :unknown]
        end
      else
        obj
      end
    end

    def self.convert_property_list_ref(plist)
      type_id = CoreFoundation.CFGetTypeID(plist);
      if type_id == CoreFoundation.CFStringGetTypeID()
        convert_string_ref(plist)
      elsif type_id == CoreFoundation.CFDictionaryGetTypeID()
        convert_dictionary_ref(plist)
      elsif type_id == CoreFoundation.CFArrayGetTypeID()
        convert_array_ref(plist)
      elsif type_id == CoreFoundation.CFNumberGetTypeID()
        convert_number_ref(plist)
      elsif type_id == CoreFoundation.CFBooleanGetTypeID()
        convert_boolean_ref(plist)
      elsif type_id == CoreFoundation.CFDataGetTypeID()
        convert_data_ref(plist)
      elsif type_id == CoreFoundation.CFDateGetTypeID()
        convert_date_ref(plist)
      else
        nil
      end
    end

    def self.convert_string_ref(plist)
      length = CoreFoundation.CFStringGetLength(plist)
      enc = 0x8000100 #kCFStringEncodingUTF8
      byte_count = ' ' * 8
      byte_count = byte_count.to_ptr if ''.respond_to?(:to_ptr)
      succ = CoreFoundation.CFStringGetBytes(plist, 0, length, enc, 0, 0, nil, 0, byte_count)
      if succ == 0
        enc = 0 #kCFStringEncodingMacRoman
        CoreFoundation.CFStringGetBytes(plist, 0, length, enc, 0, 0, nil, 0, byte_count)
      end
      buffer = ' ' * length
      buffer = buffer.to_ptr if ''.respond_to?(:to_ptr)
      byte_count = byte_count.to_s(8) if ''.respond_to?(:to_ptr)
      CoreFoundation.CFStringGetBytes(plist, 0, length, enc, 0, 0, buffer, byte_count.unpack("Q").first, nil)
      buffer = buffer.to_s if ''.respond_to?(:to_ptr)
      buffer
    end

    def self.convert_dictionary_ref(plist)
      context = {}
      applier = if CoreFoundation.const_defined?('CFDictionaryApplierFunction')
        CoreFoundation::CFDictionaryApplierFunction
      else
        DL.callback('0PPP') do |k, v, c|
          context[convert_property_list_ref(k)] = convert_property_list_ref(v)
          c
        end
      end
      CoreFoundation.CFDictionaryApplyFunction(plist, applier, '') do |k, v, c|
        context[convert_property_list_ref(k)] = convert_property_list_ref(v)
        c
      end
      if DL.const_defined?(:FuncTable)
        key = applier.name.gsub(/^rb_dl_callback_func_/, '').split(/_/, 2).map {|i| i.to_i }
        DL::FuncTable.delete(key)
      end
      context
    end

    def self.convert_array_ref(plist)
      context = []
      applier = if CoreFoundation.const_defined?('CFArrayApplierFunction')
        CoreFoundation::CFArrayApplierFunction
      else
        DL.callback('0PP') do |i, c|
          context.push(convert_property_list_ref(i))
          c
        end
      end
      count = CoreFoundation.CFArrayGetCount(plist)
      CoreFoundation.CFArrayApplyFunction(plist, 0, count, applier, '') do |i, c|
        context.push(convert_property_list_ref(i))
        c
      end      
      if DL.const_defined?(:FuncTable)
        key = applier.name.gsub(/^rb_dl_callback_func_/, '').split(/_/, 2).map {|i| i.to_i }
        DL::FuncTable.delete(key)
      end
      context
    end

    def self.convert_number_ref(plist)
      val = ' ' * 8
      val = val.to_ptr if ''.respond_to?(:to_ptr)
      if CoreFoundation.CFNumberIsFloatType(plist) == 1
        CoreFoundation.CFNumberGetValue(plist, 13, val)
        val = val.to_s(8) if ''.respond_to?(:to_ptr)
        val.unpack('d').first
      else
        CoreFoundation.CFNumberGetValue(plist, 10, val)
        val = val.to_s(8) if ''.respond_to?(:to_ptr)
        val.unpack('Q').first
      end
    end

    def self.convert_boolean_ref(plist)
      CoreFoundation.CFBooleanGetValue(plist) == 1
    end

    def self.convert_data_ref(plist)
      bytes = CoreFoundation.CFDataGetBytePtr(plist)
      len = CoreFoundation.CFDataGetLength(plist)
      str = bytes.to_s(len)
      str.blob!
      str
    end

    def self.convert_date_ref(plist)
      seconds = CoreFoundation.CFDateGetAbsoluteTime(plist)
      Time.gm(2001, 1) + seconds
    end

    def self.convert_plist_to_string(plist, _format)
      write_stream = CoreFoundation.CFWriteStreamCreateWithAllocatedBuffers(nil, nil)
      CoreFoundation.CFWriteStreamOpen(write_stream)
      error = "\x00" * 8
      error = error.to_ptr if ''.respond_to?(:to_ptr)
      CoreFoundation.CFPropertyListWriteToStream(plist, write_stream, _format, error)
      CoreFoundation.CFWriteStreamClose(write_stream)
      _error = DL::CPtr.new(error.unpack('Q').first) rescue DL::PtrData.new(error.to_s(8).unpack('Q').first)
      if ! _error.null?
        buffer_len = CoreFoundation.CFStringGetLength(_error) + 1
        buffer = ' ' * buffer_len
        buffer = buffer.to_ptr if ''.respond_to?(:to_ptr)
        CoreFoundation.CFStringGetCString(_error, buffer, buffer_len, 0x8000100)
        buffer = buffer.to_s(buffer_len) if ''.respond_to?(:to_ptr)
        raise PropertyListError.new(buffer)
      end
      data = CoreFoundation.CFWriteStreamCopyProperty(write_stream, CoreFoundation.import_symbol('kCFStreamPropertyDataWritten').ptr)
      CoreFoundation.CFRelease(write_stream)
      plist_data = convert_data_ref(data)
      CoreFoundation.CFRelease(data)
      plist_data
    end

    def self.convert_object(obj)
      case obj
      when String; convert_string(obj)
      when Hash; convert_hash(obj)
      when Array; convert_array(obj)
      when Float, Fixnum, Bignum; convert_number(obj)
      when TrueClass; CoreFoundation.import_symbol('kCFBooleanTrue').ptr
      when FalseClass; CoreFoundation.import_symbol('kCFBooleanFalse').ptr
      when Time; convert_time(obj)
      else; raise 'An object in argument tree could not be converted'
        nil
      end
    end

    def self.convert_string(obj)
      if obj.blob?
        CoreFoundation.CFDataCreate(nil, obj, obj.length)
      else
        str = CoreFoundation.CFStringCreateWithBytes(nil, obj, obj.length, 0x8000100, 0)
        str
      end
    end

    def self.convert_hash(obj)
      count = obj.size
      dict = CoreFoundation.CFDictionaryCreateMutable(nil, count, CoreFoundation.import_symbol('kCFTypeDictionaryKeyCallBacks'), CoreFoundation.import_symbol('kCFTypeDictionaryValueCallBacks'))
      obj.each do |k, v|
        CoreFoundation.CFDictionaryAddValue(dict, convert_object(k), convert_object(v))
      end
      dict
    end

    def self.convert_array(obj)
      array = CoreFoundation.CFArrayCreateMutable(nil, obj.size, CoreFoundation.import_symbol('kCFTypeArrayCallBacks').ref)
      obj.each do |item|
        v = convert_object(item)
        CoreFoundation.CFArrayAppendValue(array, v)
        #FIXME: somehow it segfaults
        #CoreFoundation.CFRelease(v)
      end
      array
    end

    def self.convert_number(obj)
      value = nil
      type = nil
      case obj
      when Float
        value = [obj].pack('d')
        type = 13 #kCFNumberDoubleType
      when Fixnum
        # FIXME: 64bit vs 32bit
        value = [obj].pack('Q')
        type = 10 # kCFNumberLongType
      when Bignum
        value = [obj].pack('Q')
        type = 11 # kCFNumberLongLongType
      else; raise 'An unknown object type passed to convert_number'
      end
      CoreFoundation.CFNumberCreate(nil, type, value)
    end

    def self.convert_time(obj)
      secs = obj - Time.gm(2001, 1)
      CoreFoundation.CFDateCreate(nil, secs)
    end
  end

  class PropertyListError < StandardError
  end
end

class Object
  def to_plist(type = :xml1)
    format = case type
    when :xml1; 100
    when :binary1; 200
    when :openstep; 1
    else; raise 'type must be one of :xml1, :binary1, or :openstep'
    end
    plist = OSX::PropertyList.convert_object(self)
    data = OSX::PropertyList.convert_plist_to_string(plist, format)
    data.blob! if [:xml1, :binary1].include?(type)
    data
  end
end