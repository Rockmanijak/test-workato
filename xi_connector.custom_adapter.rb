{
  title: "XI Connector",
    connection: {
      fields: [
        {
          name: 'client_id',
          optional: false
        },
        {
          name: 'client_secret',
          optional: false,
          control_type: 'password'
        },
        {
          name: 'im_customer_number',
          optional: false
        },
        {
          name: 'im_country_code',
          optional: false
        }
      ],

      authorization: {
        type: 'custom_auth',

        acquire: lambda do |connection|
          hash = ("#{connection['client_id']}:#{connection['client_secret']}").base64.gsub("\n", '')
          response = post('https://api.ingrammicro.com/oauth/oauth30/token'). # Token URL
                        payload(grant_type: 'client_credentials', scope: 'read').
                        headers(Authorization: "Basic " + hash).
                        request_format_www_form_urlencoded

          {
            access_token: response["access_token"],
            uuid: (0...32).map { rand(16).to_s(16) }.join
          }
        end,
        
        refresh_on: [401, 403],

        apply: lambda do |connection|
          headers(
            "Authorization" => "Bearer #{connection['access_token']}",
            "IM-CustomerNumber" => "#{connection['im_customer_number']}",
            "IM-CorrelationID" => "#{connection['uuid']}",
            "IM-CountryCode" => "#{connection['im_country_code']}"
          )
        end
      }
    },

  test: lambda do |_connection|
    get("https://api.ingrammicro.com/sandbox/resellers/v6/deals/search")
  end,

  object_definitions: {
    #  Object definitions can be referenced by any input or output fields in actions/triggers.
    #  Use it to keep your code DRY. Possible arguments - connection, config_fields
    #  See more at https://docs.workato.com/developing-connectors/sdk/sdk-reference/object_definitions.html
    create_new_order_v7_input: {
      fields: lambda do
        [
          { 
            name: 'quoteNumber',
            label: 'Quote Number',
            optional: true
          },
          { 
            name: 'customerOrderNumber',
            label: 'Customer Order Number',
            optional: false
          }, 
          { 
            name: 'endCustomerOrderNumber',
            label: 'End Customer Order Number',
            optional: false
          },
          { 
            name: 'notes',
            label: 'Notes',
            optional: false
          },
          { 
            name: 'billToAddressId',
            label: 'Bill To Address ID',
            optional: true
          },
          { 
            name: 'specialBidNumber',
            label: 'Special Bid Number',
            optional: true
          },
          { 
            name: 'acceptBackOrder',
            label: 'Accept Back Order',
            type: 'boolean',
            optional: true
          },
          { 
            name: 'vendAuthNumber',
            label: 'Vendor Auth Number',
            optional: true
          },
          { 
            name: 'resellerInfo',
            label: 'Reseller Info',
            type: 'object',
            properties: [
              { name: 'resellerId' },
              { name: 'companyName' },
              { name: 'contact' },
              { name: 'addressLine1' },
              { name: 'addressLine2' },
              { name: 'city' },
              { name: 'state' },
              { name: 'postalCode' },
              { name: 'countryCode' },
              { name: 'phoneNumber' },
              { name: 'email' }
            ],
            optional: true
          },
          { 
            name: 'endUserInfo',
            label: 'End User Info',
            type: 'object',
            properties: [
              { name: 'endUserId', optional: true },
              { name: 'contact', optional: false },
              { name: 'companyName', optional: false },
              { name: 'addressLine1', optional: false },
              { name: 'addressLine2' },
              { name: 'city', optional: false },
              { name: 'state', optional: false },
              { name: 'postalCode', optional: false },
              { name: 'countryCode', optional: false },
              { name: 'phoneNumber', optional: false },
              { name: 'email', optional: false }
            ],
            optional: false
          },
          { 
            name: 'shipToInfo',
            label: 'Ship To Info',
            type: 'object',
            properties: [
              { name: 'addressId' },
              { name: 'contact', optional: false },
              { name: 'companyName', optional: false },
              { name: 'addressLine1', optional: false },
              { name: 'addressLine2' },
              { name: 'city', optional: false },
              { name: 'state', optional: false },
              { name: 'postalCode', optional: false },
              { name: 'countryCode', optional: false },
              { name: 'email', optional: false },
              { name: 'shippingNotes' },
              { name: 'phoneNumber' }
            ],
            optional: false
          },
          { 
            name: 'shipmentDetails',
            label: 'Shipment Details',
            type: 'object',
            properties: [
              { name: 'carrierCode' },
              { name: 'requestedDeliveryDate' },
              { name: 'shipComplete' },
              { name: 'shippingInstructions' },
              { name: 'freightAccountNumber' },
              { name: 'signatureRequired', type: 'boolean' }
            ],
            optional: true
          },
          { 
            name: 'additionalAttributes',
            label: 'Additional Attributes',
            type: 'array',
            of: 'object',
            properties: [
              { name: 'attributeName' },
              { name: 'attributeValue' }
            ],
            optional: true
          },
          { 
            name: 'vmfAdditionalAttributes',
            label: 'VMF Additional Attributes',
            type: 'array',
            of: 'object',
            properties: [
              { name: 'attributeName' },
              { name: 'attributeValue' }
            ],
            optional: true
          },
          { 
            name: 'lines',
            label: 'Lines',
            type: 'array',
            of: 'object',
            properties: [
              { 
                name: 'customerLineNumber',
                optional: true
              },
              { 
                name: 'ingramPartNumber',
                optional: true
              },
              { 
                name: 'vendorPartNumber',
                optional: true
              },
              { 
                name: 'quantity', 
                type: 'number',
                optional: true
              },
              { name: 'unitPrice', type: 'number', optional: true },
              { name: 'specialBidNumber', optional: true },
              { name: 'endUserPrice', type: 'number', optional: true },
              { name: 'notes', optional: true },
              { 
                name: 'endUserInfo',
                optional: true,
                type: 'array',
                of: 'object',
                properties: [
                  { name: 'endUserId', optional: true },
                  { name: 'endUserType' },
                  { name: 'companyName' },
                  { name: 'addressLine1' },
                  { name: 'addressLine2' },
                  { name: 'contact' },
                  { name: 'city' },
                  { name: 'state' },
                  { name: 'postalCode' },
                  { name: 'countryCode' },
                  { name: 'phoneNumber', type: 'number' },
                  { name: 'email' }
                ],
              },
              { 
                name: 'additionalAttributes',
                type: 'array',
                of: 'object',
                properties: [
                  { name: 'attributeName' },
                  { name: 'attributeValue' }
                ]
              },
              { 
                name: 'warrantyInfo',
                optional: true,
                type: 'array',
                of: 'object',
                properties: [
                  { name: 'hardwareLineLink', optional: true },
                  { name: 'warrantyLineLink', optional: true },
                  { name: 'directLineLink', optional: true },
                  { 
                    name: 'serialInfo',
                    optional: true,
                    type: 'array',
                    of: 'object',
                    properties: [
                      { name: 'dateofPurchase', optional: true },
                      { name: 'shipDate', optional: true},
                      { name: 'primarySerialNumber', optional: true },
                      { name: 'secondarySerialNumber', optional: true}
                    ]
                  }
                ]
              },
              { 
                name: 'vmfAdditionalAttributesLines',
                type: 'array',
                of: 'object',
                properties: [
                  { name: 'attributeName' },
                  { name: 'attributeValue' }
                ]
              }
            ],
            optional: true
          }
        ]
      end
    },
    
    create_new_order_v7_output: {
      fields: lambda do
        [
          { 
            name: 'quoteNumber',
            label: 'Quote Number',
            optional: true
          },
          { 
            name: 'confirmationNumber',
            label: 'Confirmation Number',
            type: 'number',
            optional: true
          },
          { 
            name: 'message',
            label: 'Message',
            optional: true
          }
        ]
      end
    },
    search_order_v7_input: {
      fields: lambda do
        [
          {
            name: 'ingramOrderNumber',
            type: :string,
            control_type: :text,
            label: 'The Ingram Micro order number',
            hint: 'Max 11 characters',
            validate: lambda { |f|
              f.length <= 11 || 'Ingram Order Number must be 11 characters or less'
            }
          },
          {
            name: 'orderStatus',
            type: :string,
            label: 'Ingram Micro order status',
            control_type: 'select',
            pick_list: [
              ['Shipped', 'SHIPPED'],
              ['Processing', 'PROCESSING'],
              ['On Hold', 'ON HOLD'],
              ['Backordered', 'BACKORDERED'],
              ['Cancelled', 'CANCELLED']
            ]
          },
          {
            name: 'orderStatus_in',
            type: :array,
            of: 'string',
            hint: 'The accepted input should be in the format of ["CANCELLED","PROCESSING"]',
            label: 'Ingram Micro order status(can use it for multiple entries)'
          },

          {
            name: 'ingramOrderDate',
            type: :date,
            control_type: 'date',
            description: 'Search by Order Date',
            hint: 'Select Order Date',
            render_input: lambda { |f|
              f&.to_date&.strftime('%Y-%m-%d')
            }
          },
          {
            name: 'ingramOrderDate_bt',
            type: :object,
            label: 'Ingram Order Date Between',
            description: 'Search by Order Date between startDate and endDate',
            hint: 'Specify start and end date for Order Date range',
            properties: [
              {
                name: 'start',
                label: 'Start Date',
                type: :date,
                control_type: 'date',
                hint: 'Select Start Date'
              },
              {
                name: 'end',
                label: 'End Date',
                type: :date,
                control_type: 'date',
                hint: 'Select End Date'
              }
            ]
          },
          {
            name: 'customerOrderNumber',
            type: :string,
            control_type: :text,
            label: 'Search using PO/Order number',
            hint: 'Max 35 characters',
            validate: lambda { |f|
              f.length <= 35 || 'PO/Order Number must be 35 characters or less'
            }
          },
          {
            name: 'pageSize',
            type: :integer,
            control_type: :number,
            label: 'The number of records required in a call',
            hint: 'Max number of records per page100',
            default: 25,
            validate: lambda { |f|
              f <= 100 || 'Page Size cannot exceed 100'
            }
          },
          {
            name: 'pageNumber',
            type: :integer,
            control_type: :number,
            label: 'The Page Number reference',
            default: 1
          },
          {
            name: 'endCustomerOrderNumber',
            type: :string,
            control_type: :text,
            label: 'End customer/user purchase order number',
            hint: 'Max 35 characters',
            validate: lambda { |f|
              f.length <= 35 || 'End customer/user purchase order number must be 35 characters or less'
            }
          },
          {
            name: 'invoiceDate_bt',
            type: :object,
            label: 'Invoice Date Between',
            description: 'Invoice date of order',
            hint: 'Specify start and end date for Invoice date range',
            properties: [
              {
                name: 'start',
                label: 'Start Date',
                type: :date,
                control_type: 'date',
                hint: 'Select Start Date'
              },
              {
                name: 'end',
                label: 'End Date',
                type: :date,
                control_type: 'date',
                hint: 'Select End Date'
              }
            ]
          },
          {
            name: 'shipDate_bt',
            type: :object,
            label: 'Shipment Date Between',
            desription: 'Shipment Date of order',
            hint: 'Shipment date of order, search with the start and end date',
            properties: [
              {
                name: 'start',
                label: 'Start Date',
                type: :date,
                control_type: 'date',
                hint: 'Select Start Date'
              },
              {
                name: 'end',
                label: 'End Date',
                type: :date,
                control_type: 'date',
                hint: 'Select End Date'
              }
            ],
          },
          {
            name: 'deliveryDate_bt',
            type: :object,
            label: 'Delivery Date Between',
            description: 'Delivery date of the order',
            hint: 'Delivery date of order, search with the start and end date',
            properties: [
              {
                name: 'start',
                label: 'Start Date',
                type: :date,
                control_type: 'date',
                hint: 'Select Start Date'
              },
              {
                name: 'end',
                label: 'End Date',
                type: :date,
                control_type: 'date',
                hint: 'Select End Date'
              }
            ]
          },
          {
            name: 'ingramPartNumber',
            type: :string,
            control_type: :text,
            label: 'Ingram Micro unique part number for the product',
            hint: 'Max 35 characters',
            validate: lambda { |f|
              f.length <= 35 || 'Ingram Micro unique part number for the product must be 35 characters or less'
            }
          },
          {
            name: 'vendorPartNumber',
            type: :string,
            control_type: :text,
            label: 'Vendor’s part number for the product',
            hint: 'Max 35 characters',
            validate: lambda { |f|
              f.length <= 35 || 'Vendor’s part number for the product must be 35 characters or less'
            }
          },
          {
            name: 'serialNumber',
            type: :string,
            control_type: :text,
            label: 'A serial number of the product',
            hint: 'Max 35 characters',
            validate: lambda { |f|
              f.length <= 35 || 'A serial number of the product must be 35 characters or less'
            }
          },
          {
            name: 'trackingNumber',
            type: :string,
            control_type: :text,
            label: 'The tracking number of the order',
            hint: 'Max 35 characters',
            validate: lambda { |f|
              f.length <= 35 || 'The tracking number of the order must be 35 characters or less'
            }
          },
          {
            name: 'vendorName',
            type: :string,
            control_type: :text,
            label: 'Name of the vendor',
            hint: 'Max 35 characters',
            validate: lambda { |f|
              f.length <= 35 || 'Name of the vendor must be 35 characters or less'
            }
          },
          {
            name: 'specialBidNumber',
            type: :string,
            control_type: :text,
            label: 'The bid number provided to the reseller by the vendor for special pricing and discounts. Line-level bid numbers take precedence over header-level bid numbers',
            hint: 'Max 35 characters',
            custom_validation: lambda do |input|
              if input && input.length > 35
                error('The bid number provided to the reseller by the vendor for special pricing and discounts. Line-level bid numbers take precedence over header-level bid numbers must be 35 characters or less')
              end
            end
          }
        ]
      end
    },
    search_order_v7_output: {
      fields: lambda do
        [
          {
            name: 'recordsFound',
            type: :integer
          },
          {
            name: 'pageSize',
            type: :integer
          },
          {
            name: 'pageNumber',
            type: :integer
          },
          {
            name: 'orders',
            type: :array,
            properties: [
              {
                name: 'ingramOrderNumber',
                type: :string
              },
              {
                name: 'ingramOrderDate',
                type: :string
              },
              {
                name: 'customerOrderNumber',
                type: :string
              },
              {
                name: 'vendorSalesOrderNumber',
                type: :string
              },
              {
                name: 'vendorName',
                type: :string
              },
              {
                name: 'endUserCompanyName',
                type: :string
              },
              {
                name: 'endUserCompanyName',
                type: :string
              },
              {
                name: 'orderTotal',
                type: :number
              },
              {
                name: 'orderStatus',
                type: :string
              },
              {
                name: 'subOrders',
                type: :array,
                properties: [
                  {
                    name: 'subOrderNumber',
                    type: :string
                  },
                  {
                    name: 'subOrderTotal',
                    type: :number
                  },
                  {
                    name: 'subOrderStatus',
                    type: :string
                  },
                  {
                    name: 'links',
                    type: :array,
                    properties: [
                      {
                        name: 'topic',
                        type: :string
                      },
                      {
                        name: 'href',
                        type: :string
                      },
                      {
                        name: 'type',
                        type: :string
                      }
                    ]
                  }
                ]
              },
              {
                name: 'links',
                type: :object,
                properties: [
                  {
                    name: 'topic',
                    type: :string
                  },
                  {
                    name: 'href',
                    type: :string
                  },
                  {
                    name: 'type',
                    type: :string
                  }
                ]
              },
              {
                name: 'nextPage',
                type: :string
              },
              {
                name: 'previousPage',
                type: :string
              }
            ]
          }
        ]
      end
    }
  },

  # This implements a standard custom action for your users to unblock themselves even when no actions exist.
  # See more at https://docs.workato.com/developing-connectors/sdk/guides/building-actions/custom-action.html
  custom_action: true,

  custom_action_help: {
    learn_more_url: "https://developer.calendly.com/api-docs/YXBpOjM5NQ-calendly-api",
    learn_more_text: "Calendly documentation",
    body: "<p>Build your own Calendly action with a HTTP request. The request will be authorized with your Calendly Hana connection.</p>"
  },

  actions: {
    create_new_order_v7: {
      title: "Create New Order v7",
      subtitle: "Creates new order in XVantage",
      description: "Get <span class='provider'>Create New Order</span> " \
        "in <span class='provider'>XVantage</span>",
      help: "https://developer.ingrammicro.com/reseller/api-documentation/United_States#operation/post-createorder_v7",

      input_fields: lambda do |object_definitions|
        object_definitions['create_new_order_v7_input']
      end,

      execute: lambda do |_connection, _input, _input_schema, _output_schema|
        post("https://api.ingrammicro.com:443/sandbox/resellers/v7/orders").payload(_input)
      end,

      output_fields: lambda do |object_definitions|
        object_definitions['create_new_order_v7_output']
      end,
    },
    search_order_v7: {
      title: 'Search for Order v7',
      subtitle: 'Action for searching orders on X4C',
      description: 'Search for Order',

      input_fields: lambda { |object_definitions|
        object_definitions['search_order_v7_input']
      },

      execute: lambda { |_connection, input|
        date_params = %w[ingramOrderDate_bt invoiceDate_bt shipDate_bt deliveryDate_bt]
        array_params = %w[orderStatus_in]

        query_components = input.compact.map do |k, v|
          if date_params.include?(k)
            query_param_name = k == 'ingramOrderDate_bt' ? k.gsub('_', '-') : k
            date_values = call(:handle_date_parameters, input, k)
            date_values.map { |date| "#{query_param_name}=#{date}" }
          elsif array_params.include?(k)
            order_status_values = call(:handle_array_parameters, input, k)
            order_status_values
          else
            "#{k}=#{v}"
          end
        end.flatten

        query_string = query_components.join('&')

        url = "https://api.ingrammicro.com/sandbox/resellers/v6/orders/search?#{query_string}"
        response = get(url)
        { data: response }
      },
      output_fields: lambda { |object_definitions|
        object_definitions['search_order_v7_output']
      }
    }
  },

  triggers: {},

  pick_lists: {
    # Picklists can be referenced by inputs fields or object_definitions
    # possible arguements - connection
    # see more at https://docs.workato.com/developing-connectors/sdk/sdk-reference/picklists.html
    event_type: lambda do
      [
        # Display name, value
        %W[Event\ Created invitee.created],
        %W[Event\ Canceled invitee.canceled],
        %W[All\ Events all]
      ]
    end

    # folder: lambda do |connection|
    #   get("https://www.wrike.com/api/v3/folders")["data"].
    #     map { |folder| [folder["title"], folder["id"]] }
    # end
  },

  # Reusable methods can be called from object_definitions, picklists or actions
  # See more at https://docs.workato.com/developing-connectors/sdk/sdk-reference/methods.html
  methods: {
    handle_date_parameters: -> (input, param_name){
          param_value = input[param_name]
          values = []
          if param_value.present?
            start_date = param_value['start']
            end_date = param_value['end']
            if start_date
              values.push(start_date)
            end
            if end_date
              values.push(end_date)
            end
          end
          values
    },
    handle_array_parameters: -> (input,param_name){
          value = input[param_name]
          cleaned_value = value.sub(/^=/, '').gsub(/^\[|\]$/, '')
          value = cleaned_value.split(',').map { |s| s.strip.gsub(/^"|"$/, '') }
          name = param_name.gsub('_', '-')
          value.map { |status| "#{name}=#{status}" }
    }
  }
}
