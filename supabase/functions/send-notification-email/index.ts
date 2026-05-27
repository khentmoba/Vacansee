import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from "https://esm.sh/@supabase/supabase-js@2"
const RESEND_API_KEY = Deno.env.get('RESEND_API_KEY')
const TEST_RECIPIENT_EMAIL = Deno.env.get('TEST_RECIPIENT_EMAIL')

serve(async (req) => {
  try {
    const payload = await req.json()
    console.log("Received notification payload:", JSON.stringify(payload))
    const { record } = payload

    if (!record || !record.user_id) {
      console.error("Invalid payload structure. Missing record or user_id.")
      throw new Error("Invalid notification record")
    }
    
    // 1. Initialize Supabase Client with service role
    const supabaseClient = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
    )

    // 2. Fetch User Email and Name
    const { data: user, error: userError } = await supabaseClient
      .from('users')
      .select('email, display_name')
      .eq('id', record.user_id)
      .single()

    if (userError || !user) {
      console.error(`Error fetching user for ID ${record.user_id}: ${userError?.message}`)
      return new Response(JSON.stringify({ error: "User not found" }), { status: 404 })
    }

    console.log(`Sending email to: ${user.email} (${user.display_name}) for notification: ${record.title}`)

    // 3. Construct Email Body based on notification type and metadata
    let emailHtml = '';
    const meta = record.metadata;

    if (record.type === 'booking_request' && meta) {
      const moveInDate = meta.move_in_date ? new Date(meta.move_in_date).toLocaleDateString('en-US', {
        year: 'numeric',
        month: 'long',
        day: 'numeric'
      }) : 'N/A';
      
      const totalAmount = meta.monthly_rate && meta.duration_months ? meta.monthly_rate * meta.duration_months : 0;
      const formattedRate = meta.monthly_rate ? `₱${meta.monthly_rate.toLocaleString('en-US')}` : 'N/A';
      const formattedTotal = totalAmount ? `₱${totalAmount.toLocaleString('en-US')}` : 'N/A';

      emailHtml = `
        <!DOCTYPE html>
        <html>
        <body style="font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif; background-color: #f8fbfd; padding: 40px; margin: 0;">
          <div style="max-width: 600px; margin: 0 auto; background-color: #ffffff; border-radius: 16px; overflow: hidden; box-shadow: 0 4px 12px rgba(0,0,0,0.05);">
            <div style="background-color: #5287B2; padding: 32px; text-align: center;">
              <h1 style="color: #ffffff; margin: 0; font-size: 24px; font-weight: 700; letter-spacing: -0.5px;">VacanSee</h1>
            </div>
            <div style="padding: 40px; color: #333333; line-height: 1.6;">
              <h2 style="color: #1a1a1a; margin-top: 0; font-size: 20px; font-weight: 600;">Hello, ${user.display_name}!</h2>
              <p style="font-size: 16px; color: #4a4a4a; margin-bottom: 24px;">You have received a new booking request. Here are the details:</p>
              
              <div style="background-color: #f8fafc; border: 1px solid #e2e8f0; border-radius: 12px; padding: 24px; margin-bottom: 32px;">
                <h3 style="margin-top: 0; color: #5287B2; font-size: 16px; font-weight: 600; border-bottom: 1px solid #e2e8f0; padding-bottom: 8px; margin-bottom: 16px;">Booking Information</h3>
                <table style="width: 100%; border-collapse: collapse; font-size: 14px;">
                  <tr>
                    <td style="padding: 6px 0; color: #64748b; font-weight: 500; width: 140px;">Property</td>
                    <td style="padding: 6px 0; color: #0f172a; font-weight: 600;">${meta.property_name || 'N/A'}</td>
                  </tr>
                  <tr>
                    <td style="padding: 6px 0; color: #64748b; font-weight: 500;">Room Description</td>
                    <td style="padding: 6px 0; color: #0f172a;">${meta.room_description || 'N/A'}</td>
                  </tr>
                  <tr>
                    <td style="padding: 6px 0; color: #64748b; font-weight: 500;">Monthly Rate</td>
                    <td style="padding: 6px 0; color: #0f172a; font-weight: 600;">${formattedRate}</td>
                  </tr>
                  <tr>
                    <td style="padding: 6px 0; color: #64748b; font-weight: 500;">Move-In Date</td>
                    <td style="padding: 6px 0; color: #0f172a;">${moveInDate}</td>
                  </tr>
                  <tr>
                    <td style="padding: 6px 0; color: #64748b; font-weight: 500;">Duration</td>
                    <td style="padding: 6px 0; color: #0f172a;">${meta.duration_months || 1} Month(s) (Total: ${formattedTotal})</td>
                  </tr>
                </table>

                <h3 style="margin-top: 24px; color: #5287B2; font-size: 16px; font-weight: 600; border-bottom: 1px solid #e2e8f0; padding-bottom: 8px; margin-bottom: 16px;">Tenant Details</h3>
                <table style="width: 100%; border-collapse: collapse; font-size: 14px;">
                  <tr>
                    <td style="padding: 6px 0; color: #64748b; font-weight: 500; width: 140px;">Name</td>
                    <td style="padding: 6px 0; color: #0f172a; font-weight: 600;">${meta.student_name || 'N/A'}</td>
                  </tr>
                  <tr>
                    <td style="padding: 6px 0; color: #64748b; font-weight: 500;">Email</td>
                    <td style="padding: 6px 0; color: #0f172a;"><a href="mailto:${meta.student_email}" style="color: #5287B2; text-decoration: none;">${meta.student_email || 'N/A'}</a></td>
                  </tr>
                  <tr>
                    <td style="padding: 6px 0; color: #64748b; font-weight: 500;">Phone Number</td>
                    <td style="padding: 6px 0; color: #0f172a;">${meta.student_phone || 'N/A'}</td>
                  </tr>
                  ${meta.student_notes ? `
                  <tr>
                    <td style="padding: 6px 0; color: #64748b; font-weight: 500; vertical-align: top;">Notes</td>
                    <td style="padding: 6px 0; color: #334155; font-style: italic; background: #f1f5f9; padding: 10px; border-radius: 6px; margin-top: 4px; display: block;">"${meta.student_notes}"</td>
                  </tr>
                  ` : ''}
                </table>
              </div>

              <div style="margin-top: 32px; text-align: center;">
                <a href="https://vacansee.vercel.app" style="background-color: #5287B2; color: #ffffff; padding: 14px 28px; text-decoration: none; border-radius: 8px; font-weight: 600; display: inline-block; box-shadow: 0 4px 10px rgba(82, 135, 178, 0.3);">Review Booking Request</a>
              </div>
            </div>
            <div style="background-color: #f8fafc; border-top: 1px solid #f1f5f9; padding: 24px; text-align: center; font-size: 12px; color: #64748b;">
              <p style="margin: 0 0 8px 0;">&copy; 2026 VacanSee. All rights reserved.</p>
              <p style="margin: 0;">Cagayan de Oro City, Philippines</p>
            </div>
          </div>
        </body>
        </html>
      `;
    } else if ((record.type === 'booking_accepted' || record.type === 'booking_declined') && meta) {
      const isApproved = record.type === 'booking_accepted';
      const statusColor = isApproved ? '#22c55e' : '#ef4444';
      const statusText = isApproved ? 'APPROVED' : 'DECLINED';
      
      emailHtml = `
        <!DOCTYPE html>
        <html>
        <body style="font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif; background-color: #f8fbfd; padding: 40px; margin: 0;">
          <div style="max-width: 600px; margin: 0 auto; background-color: #ffffff; border-radius: 16px; overflow: hidden; box-shadow: 0 4px 12px rgba(0,0,0,0.05);">
            <div style="background-color: #5287B2; padding: 32px; text-align: center;">
              <h1 style="color: #ffffff; margin: 0; font-size: 24px; font-weight: 700; letter-spacing: -0.5px;">VacanSee</h1>
            </div>
            <div style="padding: 40px; color: #333333; line-height: 1.6;">
              <h2 style="color: #1a1a1a; margin-top: 0; font-size: 20px; font-weight: 600;">Hello, ${user.display_name}!</h2>
              <p style="font-size: 16px; color: #4a4a4a; margin-bottom: 24px;">Your booking request status has been updated.</p>
              
              <div style="background-color: #f8fafc; border: 1px solid #e2e8f0; border-radius: 12px; padding: 24px; margin-bottom: 32px; text-align: center;">
                <span style="display: inline-block; background-color: ${statusColor}15; color: ${statusColor}; font-weight: 800; font-size: 14px; padding: 8px 16px; border-radius: 9999px; margin-bottom: 16px; letter-spacing: 0.5px;">
                  BOOKING ${statusText}
                </span>
                
                <table style="width: 100%; border-collapse: collapse; font-size: 14px; text-align: left; margin-top: 16px;">
                  <tr>
                    <td style="padding: 6px 0; color: #64748b; font-weight: 500; width: 140px;">Property</td>
                    <td style="padding: 6px 0; color: #0f172a; font-weight: 600;">${meta.property_name || 'N/A'}</td>
                  </tr>
                  <tr>
                    <td style="padding: 6px 0; color: #64748b; font-weight: 500;">Room Description</td>
                    <td style="padding: 6px 0; color: #0f172a;">${meta.room_description || 'N/A'}</td>
                  </tr>
                  ${meta.owner_notes ? `
                  <tr>
                    <td style="padding: 6px 0; color: #64748b; font-weight: 500; vertical-align: top;">Owner Message</td>
                    <td style="padding: 6px 0; color: #334155; font-style: italic; background: #f1f5f9; padding: 10px; border-radius: 6px; margin-top: 4px; display: block;">"${meta.owner_notes}"</td>
                  </tr>
                  ` : ''}
                </table>
              </div>

              <div style="margin-top: 32px; text-align: center;">
                <a href="https://vacansee.vercel.app" style="background-color: #5287B2; color: #ffffff; padding: 14px 28px; text-decoration: none; border-radius: 8px; font-weight: 600; display: inline-block; box-shadow: 0 4px 10px rgba(82, 135, 178, 0.3);">Go to Dashboard</a>
              </div>
            </div>
            <div style="background-color: #f8fafc; border-top: 1px solid #f1f5f9; padding: 24px; text-align: center; font-size: 12px; color: #64748b;">
              <p style="margin: 0 0 8px 0;">&copy; 2026 VacanSee. All rights reserved.</p>
              <p style="margin: 0;">Cagayan de Oro City, Philippines</p>
            </div>
          </div>
        </body>
        </html>
      `;
    } else {
      // Fallback for general or non-metadata notifications
      emailHtml = `
        <!DOCTYPE html>
        <html>
        <body style="font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif; background-color: #f8fbfd; padding: 40px; margin: 0;">
          <div style="max-width: 600px; margin: 0 auto; background-color: #ffffff; border-radius: 16px; overflow: hidden; box-shadow: 0 4px 12px rgba(0,0,0,0.05);">
            <div style="background-color: #5287B2; padding: 32px; text-align: center;">
              <h1 style="color: #ffffff; margin: 0; font-size: 24px; font-weight: 700; letter-spacing: -0.5px;">VacanSee</h1>
            </div>
            <div style="padding: 40px; color: #333333; line-height: 1.6;">
              <h2 style="color: #1a1a1a; margin-top: 0; font-size: 20px; font-weight: 600;">Hello, ${user.display_name}!</h2>
              <p style="font-size: 16px; color: #4a4a4a; margin-bottom: 24px;">${record.message}</p>
              <div style="margin-top: 32px; text-align: center;">
                <a href="https://vacansee.vercel.app" style="background-color: #5287B2; color: #ffffff; padding: 14px 28px; text-decoration: none; border-radius: 8px; font-weight: 600; display: inline-block; box-shadow: 0 4px 10px rgba(82, 135, 178, 0.3);">View in Dashboard</a>
              </div>
            </div>
            <div style="background-color: #f8fafc; border-top: 1px solid #f1f5f9; padding: 24px; text-align: center; font-size: 12px; color: #64748b;">
              <p style="margin: 0 0 8px 0;">&copy; 2026 VacanSee. All rights reserved.</p>
              <p style="margin: 0;">Cagayan de Oro City, Philippines</p>
            </div>
          </div>
        </body>
        </html>
      `;
    }

    // 4. Send Email via Resend
    // Note: 'from' address must be verified in Resend. 'onboarding@resend.dev' works for testing.
    // If TEST_RECIPIENT_EMAIL is configured, send to that email instead of user.email for testing purposes.
    const recipientEmail = TEST_RECIPIENT_EMAIL || user.email;
    console.log(`Sending email to: ${recipientEmail} (Original owner email: ${user.email}) for notification: ${record.title}`);

    const res = await fetch('https://api.resend.com/emails', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${RESEND_API_KEY}`,
      },
      body: JSON.stringify({
        from: 'VacanSee <onboarding@resend.dev>',
        to: [recipientEmail],
        subject: `[VacanSee] ${record.title}`,
        html: emailHtml,
      }),
    })

    const result = await res.json()
    
    if (!res.ok) {
      console.error(`Resend API Error details: ${JSON.stringify(result)}`)
      throw new Error(`Resend API Error: ${res.status} - ${JSON.stringify(result)}`)
    }

    return new Response(JSON.stringify({ success: true, message_id: result.id }), { 
      headers: { 'Content-Type': 'application/json' },
      status: 200 
    })
  } catch (error) {
    console.error(`Edge Function Failure: ${error.message}`)
    return new Response(JSON.stringify({ error: error.message }), { 
      headers: { 'Content-Type': 'application/json' },
      status: 500 
    })
  }
})
